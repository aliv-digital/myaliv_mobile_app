# Auth Flow — JWT with Refresh, Bearer Interceptor, and TTL Behavior

MyALIV mobile authenticates against the Kansys JWT API. Every authenticated
request carries `Authorization: Bearer <access_token>`, injected by a single
Dio interceptor. Session tokens are persisted in `flutter_secure_storage`,
refreshed proactively and reactively via single-flight logic, and rotated
on every refresh.

This document is the source of truth for how tokens live, expire, refresh,
and die. If you're touching anything under `packages/core/lib/src/auth/` or
`packages/core/lib/src/network/bearer_auth_interceptor.dart`, read this
first.

---

## 1. The moving parts

| Component | File | Responsibility |
|---|---|---|
| `TokenSession` | `packages/core/lib/src/auth/token_session.dart` | Immutable value: `accessToken`, `refreshToken`, and absolute expiry instants. |
| `TokenStore` | `packages/core/lib/src/auth/token_store.dart` | `flutter_secure_storage` persistence (4 keys). |
| `AuthManager` | `packages/core/lib/src/auth/auth_manager.dart` | In-memory session, load/save/clear, single-flight refresh. |
| `BearerAuthInterceptor` | `packages/core/lib/src/network/bearer_auth_interceptor.dart` | Injects Bearer on every request, orchestrates refresh + retry. |
| `NetworkService` | `packages/core/lib/src/network/network_service.dart` | Shared Dio + interceptor chain: `CookieManager → BearerAuthInterceptor → Logging`. |
| `ApiService` (`http`) | `lib/core/networkService/app_http_client.dart` | Legacy `http` client; default `tokenProvider` reads `AuthManager` and calls `refreshIfNeeded` when the access token is expired. |
| `performHardLogout()` | `lib/core/auth/hard_logout.dart` | Wipes session, cubits, cookies, cancels in-flight requests, navigates to `/welcome`. |
| `AuthCompletionService` | `lib/app/Aliv-Mobile/login/services/auth_completion_service.dart` | Post-token orchestration: saveSession → fetch `/Account` → fetch `/Account/devices` → UI config. |

---

## 2. Storage layout

### Secure storage (encrypted at rest)
`flutter_secure_storage`, 4 keys — never SharedPreferences:

```
auth.access_token          String  — the JWT access token
auth.refresh_token         String  — the JWT refresh token
auth.access_expires_at     String  — ISO-8601 absolute instant
auth.refresh_expires_at    String  — ISO-8601 absolute instant
```

Absolute instants are stored — **not** TTL durations — so app restarts
compute expiry correctly regardless of how long the app was closed.

### In-memory
`AuthManager._session: TokenSession?` — mirror of the persisted state.
Every read at request time goes through this, not disk.

### SharedPreferences (non-auth shim)
`LocalStorage.accountID` — the **primary device's `DeviceID`** (from
`/Account/devices`), populated by `AuthCompletionService` after login. Some
legacy URL builders still read this key. Do not confuse with the account's
`id_acc` (from `/Account`) — those are different numbers and passing the
wrong one to `/device/{id}/...` yields `501 InvalidDevice`.

---

## 3. TTLs — how they're computed, stored, checked, refreshed

### Where TTLs come from
The auth API returns durations in seconds:
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 900,
  "refresh_expires_in": 2592000
}
```
Currently 900 s (15 min) / 2,592,000 s (30 days) — **server-configurable**;
never hardcoded on the client. Any change on the backend is picked up on
the next login or refresh with no client deploy.

### How they're stored
`TokenSession.fromLoginJson` computes:
```
accessExpiresAt  = DateTime.now() + Duration(seconds: expires_in)
refreshExpiresAt = DateTime.now() + Duration(seconds: refresh_expires_in)
```
Both instants are persisted as ISO-8601 strings. Boot-time hydration parses
them back with `DateTime.parse`.

### How they're checked
`TokenSession` exposes two getters, both computed against `DateTime.now()`:
```dart
bool get accessExpired  =>
    DateTime.now().isAfter(accessExpiresAt.subtract(_skew));   // _skew = 30s

bool get refreshExpired =>
    DateTime.now().isAfter(refreshExpiresAt);                  // no skew
```

The **30-second clock skew on access** ensures we refresh proactively a
bit before the server thinks the token has expired — covers device clock
drift and in-flight requests that would otherwise 401 mid-flight.

### Rotation policy — full pair, always
Every successful refresh returns a **new** `access_token` **and** a **new**
`refresh_token` with **fresh** TTLs (not remaining time from the old
refresh). Both tokens are replaced atomically via `saveSession`, which
writes to memory and secure storage.

**Practical implication:**
- An **active user** — one who makes at least one authed request every 30 days
  — will *never* see their refresh token expire. Each refresh resets the
  30-day clock, forming a rolling window.
- An **idle user** — no requests for 30+ days — has an expired refresh
  token. Next request → `refreshExpired == true` → hard logout → welcome
  screen.
- The **access token** rolls over every ~15 min transparently. Users never
  see it happen.

### What happens under different failure modes

The refresh call at `AuthManager._doRefresh()` classifies failures so a
bad wifi moment doesn't kick the user out:

| Failure | `_doRefresh` returns | Interceptor / caller does |
|---|---|---|
| 4xx from `/Auth/refresh` (server rejected refresh token) | `null` | `onHardLogout()` → back to login |
| Malformed body (missing token, non-positive TTL) | `null` | `onHardLogout()` → back to login |
| Non-JSON body | `null` | `onHardLogout()` → back to login |
| 5xx from `/Auth/refresh` | **current (stale) session** | Inject stale token, request proceeds. Server likely 401s; caller surfaces a network error; **session stays**; next request retries the refresh. |
| Timeout / no network | **current (stale) session** | Same as 5xx above. |

The distinction between transient and hard failure is what prevents
temporary connectivity from destroying valid sessions.

---

## 4. The bearer interceptor

`BearerAuthInterceptor` is a `QueuedInterceptor` — `onRequest` is
serialized, so during a refresh all other queued requests wait and read
the **new** token afterward. No thundering herd.

### Bypass rules (skipAuth)
Two conditions bypass Bearer injection entirely:

1. `options.extra['skipAuth'] == true` — auth endpoints set this
   themselves (`/Auth/login`, `/Auth/2fa/verify`, `/Auth/2fa/resend`,
   `/Auth/refresh`, `/Auth/logout`).
2. `options.uri.host == 'myalivappuat-api.bealiv.com'` — the CMS/public
   host (best-plans, ads-timer, app-settings/*) which is authless.

### The onRequest algorithm
```
1. If skipAuth or public host  → pass through, no Bearer header.
2. If session == null           → reject with synthetic 401.
3. If session.refreshExpired    → onHardLogout(); reject with synthetic 401.
4. If session.accessExpired     → refreshIfNeeded()
     - null returned            → onHardLogout(); reject.
     - session returned         → inject fresh Bearer, proceed.
5. Otherwise                    → inject current Bearer, proceed.
```

### The onError algorithm (reactive 401 retry)
```
If 401 && !isAuthCall && !alreadyRetried:
  refreshed = refreshIfNeeded()
  if refreshed:
    mark opts.extra['authRetried'] = true
    replace Bearer with new access token
    retry via retryDio.fetch(opts)   ← bare Dio, no interceptors
    on retry success: handler.resolve(response)  (caller never sees the 401)
    on retry failure: fall through to normal error flow
  else:
    onHardLogout()
```

### Why a separate `retryDio`
Retries can't go through the intercepted Dio — the interceptor's own
onError would re-enter onError recursively. `retryDio` is a bare Dio with
the same `BaseOptions` but **no** interceptors and **no** cookies.

---

## 5. Single-flight refresh

`AuthManager.refreshIfNeeded()` guarantees N concurrent expired requests
coalesce into **exactly ONE** `/Auth/refresh` network call:

```dart
Future<TokenSession?>? _refreshInFlight;

Future<TokenSession?> refreshIfNeeded() {
  return _refreshInFlight ??=
      _doRefresh().whenComplete(() => _refreshInFlight = null);
}
```

Dart is single-threaded, so `_refreshInFlight ??= ...` is atomic in the
event loop. All concurrent callers await the same Future, get the same
result, and only ONE `/Auth/refresh` request goes out.

---

## 6. End-to-end flows

### 6.1 Login — direct (no 2FA)

```
User taps Login
  ↓
LoginBloc → POST /Auth/login  { Username, Password, Channel: "SelfCare" }  [skipAuth]
  ↓
Repo parses response body defensively:
  - contains access_token          → LoginSuccess(TokenSession)
  - contains mfa_token/TwoFactorKey → LoginMfaChallenge(mfaToken)
  ↓
LoginSuccess branch:
  AuthCompletionService.complete(session, appUiConfigCubit)
    1. AuthManager.saveSession(session)      ← memory + secure storage
    2. AccountInfoCubit.fetchAccountInfo(forceRefresh: true)  ← /Account
    3. DeviceLimitsCubit.loadDeviceLimits(forceRefresh: true) ← /Account/devices
    4. LocalStorage.storeAccountID(primaryDevice.deviceId)    ← shim
    5. AppUiConfigCubit.setConfig(prepaid/postpaid)
  ↓
Navigate to /home
```

### 6.2 Login — 2FA (OTP)

```
User taps Login
  ↓
LoginBloc → POST /Auth/login (as above)
  ↓
LoginMfaChallenge branch:
  Navigate to /otp with mfaToken + phone
  ↓
User enters 6-digit code
  ↓
LoginOtpBloc → POST /Auth/2fa/verify
  { PhoneNumber, mfa_token, otp_code, Channel: "SelfCare" }   [skipAuth]
  ↓
Response = same token-pair envelope as login (access_token, refresh_token,
                                              expires_in, refresh_expires_in)
  ↓
AuthCompletionService.complete(session, ...)   ← same as 6.1
  ↓
Navigate to /home
```

Resend path: `POST /Auth/2fa/resend { PhoneNumber, Key: mfaToken }`. The
backend may rotate the mfa token; the bloc stores whichever `Key` the
response returns.

### 6.3 Cold start with persisted session

```
App launches
  ↓
CoreInjection.initInjection()
  1. Register AuthManager
  2. authManager.loadSession()   ← reads secure storage; sets _session
  3. Register NetworkService
  4. networkService.init()       ← wires BearerAuthInterceptor; reads session lazily
  ↓
main.dart reads AccountInfoCubit (HydratedBloc) cached state,
  builds initial HomeUiConfig(userType), passes to AppUiConfigCubit
  ↓
Router mounts. Splash → checks AuthManager.currentSession:
  - null OR refreshExpired  → welcome screen
  - valid                    → home screen
  ↓
First authed request → interceptor injects Bearer.
  If accessExpired: refresh happens transparently, request proceeds
  with the new token.
```

### 6.4 Steady state — access still fresh

Every request: `onRequest` reads `currentSession`, checks `accessExpired`
(with 30 s skew). False → inject header → pass. **No** refresh calls
happen.

### 6.5 Access token expires (refresh still valid) — proactive refresh

**Via Dio (feature repos using `NetworkService`):**
1. Next request enters `onRequest`. `accessExpired == true`,
   `refreshExpired == false`.
2. `refreshIfNeeded()` — first caller starts the refresh, stores the
   Future.
3. Any concurrent requests hit `onRequest` (serialized by
   `QueuedInterceptor`), get the **same** Future — one `/Auth/refresh`
   goes out.
4. `_doRefresh` POSTs `{refresh_token}` on the bare `_authDio` (no
   interceptors, no cookies, no recursion risk).
5. Server returns a **fresh pair**. `TokenSession.fromLoginJson` computes
   new expiries. `saveSession` overwrites memory + secure storage.
6. All queued requests wake up, inject the **new** access token, proceed.

**Via `http`/`ApiService`:**
1. Caller invokes `postJson(...)`. `_defaultBearerTokenProvider` runs.
2. Sees `accessExpired && !refreshExpired` → awaits `refreshIfNeeded()`
   — same single-flight future as Dio uses.
3. Returns the new access token. Request goes out with it.

### 6.6 Access token expires mid-request — reactive refresh

Only reachable on Dio:
1. Request went out with a fresh-enough token but server 401s (clock
   skew, race, etc.).
2. `onError` sees 401, not skipAuth, not already retried → refresh.
3. New session → set `extra['authRetried'] = true`, replace
   `Authorization`, replay via bare `retryDio.fetch(opts)` →
   `handler.resolve(response)`. The caller **never sees the 401**.
4. If the retry itself fails, falls through to normal error flow. The
   `authRetried` flag prevents infinite loops.

### 6.7 Refresh token itself expires (30-day cap)

1. Next request → `onRequest` sees `refreshExpired == true`.
2. Skips refresh entirely, calls `onHardLogout()` synchronously, rejects
   the request.
3. `performHardLogout` clears:
   - `TokenStore` + memory session
   - All per-user cubits (AccountInfo, Plans, Balance, Offers,
     BestPlans, BucketUsage, ConsumptionLimit, DeviceLimits)
   - `LocalStorage.clearAll()`
   - Cookies
   - In-flight requests (`cancelAllRequests`)
4. Navigates to `/welcome` via `rootNavigatorKey.currentContext.go(...)`.

### 6.8 Explicit logout

1. `LogoutRepository.logout()` reads `currentSession.accessToken` and
   POSTs `/Auth/logout { access_token }` with `skipAuth: true`
   (best-effort; failures ignored — local logout must proceed so users
   don't get stuck).
2. Then calls `performHardLogout()` — same cleanup as 6.7.

---

## 7. Refresh endpoint contract

**Request**
```
POST {baseUrl}/v1/MyAliv/Auth/refresh
Body: { "refresh_token": "<current>" }
```

**Response (success)**
```json
{
  "access_token": "...",         // NEW
  "refresh_token": "...",        // NEW (rotated)
  "expires_in": 900,             // fresh 15-min window
  "refresh_expires_in": 2592000  // fresh 30-day window
}
```

Both tokens are replaced. Both TTLs are fresh, not remaining. The
`_doRefresh` implementation logs `REFRESH RAW BODY: $data` in debug
builds as a first-run confirmation aid — if the backend ever uses
different key names, the mismatch is visible in the first log line
instead of a silent failure loop.

**Response (server-side error, refresh token dead)** — 4xx status →
`onHardLogout()` path.

---

## 8. What NEVER happens (design invariants)

- **No token is ever passed as a parameter to feature code.** The
  interceptor and the `ApiService` default provider both read from
  `AuthManager` lazily.
- **No feature code refreshes tokens.** Only `AuthManager.refreshIfNeeded()`
  touches `/Auth/refresh`.
- **No two refresh calls in flight simultaneously.** Single-flight is
  enforced at the `AuthManager` level; both Dio and `http` paths share
  the same Future.
- **No hard-logout on transient network errors.** Only 4xx / malformed /
  non-JSON / missing session triggers it. 5xx / timeouts / connection
  errors keep the session alive.
- **No stale token stored across a rotation.** `saveSession` overwrites
  both memory and disk on every success, including refresh.
- **No TTLs hardcoded on the client.** All expiries derive from the
  server's `expires_in` / `refresh_expires_in`.

---

## 9. Testing checklist (manual QA)

Run against the mock service with the primary test credentials
(`2428997105 / aliv@2025`).

- [ ] **Cold login** — enter creds, land on home; observe
      `REFRESH RAW BODY` never logs (no refresh yet), Bearer header is
      present on every subsequent request.
- [ ] **Cold restart with valid session** — kill app, relaunch; splash
      goes straight to home, no re-login, Bearer header on first
      request. Prepaid/postpaid tabs match the account (fixed via
      `AppUiConfigCubit` boot seed).
- [ ] **Proactive refresh** — wait 15 min (or reduce `expires_in`
      server-side); trigger any authed request; observe **one** call to
      `/Auth/refresh` followed by the original request. Log shows
      `REFRESH RAW BODY: {...}` then `RESPONSE [200]` for the original
      URL.
- [ ] **Concurrent proactive refresh** — with an expired access token,
      trigger multiple authed requests simultaneously (e.g., open Plans
      tab which fires several parallel calls). Observe **exactly one**
      `/Auth/refresh` call in logs, then all originals succeed.
- [ ] **Reactive 401 retry** — force a 401 (e.g., manually corrupt the
      access token via debugger). Observe interceptor refreshes, retries
      the original, caller sees `Response [200]`, not an error.
- [ ] **Refresh token expired** — clear `auth.refresh_expires_at` to a
      past instant. Next request → hard logout → welcome screen. Check
      that account info + all per-user cubits are cleared.
- [ ] **Transient network error during refresh** — turn off wifi during
      the refresh call. Session must **not** be cleared; the current
      request errors out with a network error; on reconnect, next
      request retries the refresh successfully.
- [ ] **Explicit logout** — tap logout; observe `POST /Auth/logout`,
      then session/cubits cleared, welcome screen.
- [ ] **Logout with dead network** — turn off wifi, tap logout; the
      logout API call fails silently but local state still clears and
      user lands on welcome.
- [ ] **Re-login after logout** — new tokens issued, new session
      persisted, home screen reflects new account.

---

## 10. Follow-up work (known, not in this PR)

- **Migrate `ApiService`-based repos to `NetworkService`.** ~19 feature
  repos still use the `http`-based `ApiService`. They currently get
  proactive refresh via the default `tokenProvider`, but **not**
  reactive 401 retry — a 401 from clock skew surfaces to the user
  instead of being retried. Bounded blast radius but worth doing.
- **Partial-completion recovery.** If `AccountInfoCubit.fetchAccountInfo()`
  throws right after tokens are saved, the app has a session but no
  account info. Next cold start goes to home and fails. Fix would be
  to wrap `AuthCompletionService.complete` in a try/rollback that calls
  `clearSession` on failure.
- **`AccountInfoState.isPrepaid` / `.isPostpaid` should delegate to
  `PaymentOption.parse`.** Currently a raw `== "PrePay"` string
  comparison — a backend variant like `"PrePaid"` would misclassify.

---

## 11. Debug aids in the code

Two `debugPrint` first-run confirmations are wired for the auth path:

- **`LOGIN RAW BODY: {...}`** — in `LoginRepository.login`, logs the
  entire response body so the MFA branch shape can be verified without
  a rebuild. See `lib/app/Aliv-Mobile/login/repository/auth_repository.dart`.
- **`REFRESH RAW BODY: {...}`** — in `AuthManager._doRefresh`, logs the
  entire refresh response. If field names ever drift, the mismatch is
  immediately visible.

Both are gated by `kDebugMode` and won't ship in release builds.
