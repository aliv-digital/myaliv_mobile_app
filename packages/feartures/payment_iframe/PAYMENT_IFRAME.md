# payment_iframe — 3DS Payment Gateway Package

Drop-in Flutter package for HTML-based 3DS payment flows (PowerTranz gateway). Handles the full cycle: API call → HTML form render → WebView → Kaptcha fingerprinting → 3DS challenge → redirect interception → result callback.

---

## Payment Flow

```
Caller screen
    │
    ▼
PaymentIFrameScreen (push via Navigator)
    │  calls PaymentIFrameCubit.initiate(request)
    ▼
PaymentIFrameApiService  POST /endpoint  (skipAuth if !requiresAuth)
    │  response: { "html": "<form ...>...</form>" }
    ▼
PaymentWebViewWidget  loadHtmlString(htmlContent)
    │  shimmer overlay fades out on onPageFinished
    ▼
WebView renders PowerTranz page
    │  Kaptcha device fingerprinting (JS, automatic)
    │  User fills card details → submits form → 3DS challenge
    ▼
Gateway redirects to  myaliv://topup-callback?status=success&...
    │  NavigationDelegate intercepts scheme == redirectScheme
    │  → NavigationDecision.prevent (stops WebView from navigating)
    ▼
PaymentIFrameCubit.onRedirectReceived(uri)
    │  status == "success" | "completed"  →  PaymentSuccess
    │  otherwise                          →  PaymentFailure
    ▼
onSuccess / onFailure callback fires in caller screen
```

---

## Package Structure

```
packages/feartures/payment_iframe/
├── lib/
│   ├── payment_iframe.dart          # Public barrel export
│   └── src/
│       ├── models/
│       │   ├── payment_request.dart # Endpoint-agnostic request descriptor
│       │   └── payment_result.dart  # Sealed PaymentSuccess / PaymentFailure
│       ├── repository/
│       │   ├── payment_iframe_repository.dart
│       │   └── services/
│       │       └── payment_iframe_api_service.dart  # POST + HTML extraction
│       ├── cubit/
│       │   ├── payment_iframe_cubit.dart  # Cubit (not BLoC/events)
│       │   └── payment_iframe_state.dart  # 5-status state
│       ├── view/
│       │   └── payment_iframe_screen.dart # Drop-in screen
│       ├── widgets/
│       │   ├── payment_webview_widget.dart  # WebView + shimmer stack
│       │   └── payment_shimmer_widget.dart  # PowerTranz skeleton
│       └── payment_iframe_injection.dart    # GetIt DI registration
└── pubspec.yaml
```

---

## Usage

### 1. Push the payment screen

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => PaymentIFrameScreen(
      // Optional: pass your branded AppBar (must be PreferredSizeWidget)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: DefaultAppBar(
          title: 'complete top-up',
          backgroundColor: const Color(0xFF645D9C),
        ),
      ),
      request: PaymentRequest(
        endpoint: Api.guestTopupUrl,          // defined in api_paths.dart
        body: {
          'Amount': total,
          'PhoneNumber': phoneNumber.replaceAll(RegExp(r'\D'), ''),
          'RedirectURL': 'myaliv://topup-callback',
          'Branch': 'branch',
          'ChannelType': 'selfCare',
        },
        redirectScheme: 'myaliv',
        requiresAuth: false,                  // true for authenticated endpoints
      ),
      onSuccess: (result) {
        // result.queryParams contains all redirect URI params
        // result.orderId is extracted from 'orderId' param if present
        router.go(AppRoutes.guestTopUpReceipt, extra: { ... });
      },
      onFailure: (_) {
        // _ErrorView "Go Back" handles failure UX by default
        // pass a handler here if you need custom failure navigation
      },
    ),
  ),
);
```

### 2. AppBar customization

`PaymentIFrameScreen` accepts `appBar: PreferredSizeWidget?`. When omitted it falls back to `AppBar(title: Text(title))`.

**Important**: The main app's `DefaultAppBar` is a plain `StatelessWidget`, not a `PreferredSizeWidget`. Wrap it:

```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(64),
  child: DefaultAppBar(title: 'complete top-up'),
),
```

### 3. Authenticated vs guest endpoints

```dart
// Guest (no auth header) — default
PaymentRequest(
  ...,
  requiresAuth: false,   // or omit — false is the default
)

// Authenticated (include Bearer token)
PaymentRequest(
  ...,
  requiresAuth: true,
)
```

`PaymentIFrameApiService` passes `Options(extra: {'skipAuth': true})` for guest requests. The app's `BearerAuthInterceptor` already checks this flag and skips token injection.

---

## Models

### PaymentRequest

```dart
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.endpoint,       // full URL or path segment
    required this.body,           // POST body as Map<String, dynamic>
    required this.redirectScheme, // URI scheme to intercept (e.g. 'myaliv')
    this.requiresAuth = false,
  });
}
```

### PaymentResult (sealed)

```dart
sealed class PaymentResult {}

final class PaymentSuccess extends PaymentResult {
  final String? orderId;                  // from redirect URI 'orderId' param
  final Map<String, String> queryParams;  // all redirect URI params
}

final class PaymentFailure extends PaymentResult {
  final String message;
}
```

---

## API Contract

### Request

```
POST <endpoint>
Content-Type: application/json
Authorization: Bearer <token>   ← omitted when requiresAuth = false

{
  "Amount": 25.00,
  "PhoneNumber": "2428999726",
  "RedirectURL": "myaliv://topup-callback",
  "Branch": "branch",
  "ChannelType": "selfCare"
}
```

### Response

```json
{
  "html": "<!DOCTYPE html><html>...PowerTranz form with Kaptcha...</html>"
}
```

The `html` field content is loaded directly into the WebView via `loadHtmlString`. JavaScript is enabled (`JavaScriptMode.unrestricted`) to support Kaptcha fingerprinting and form auto-submission.

### Redirect (success)

```
myaliv://topup-callback?status=success&orderId=TXN123&...
```

### Redirect (failure)

```
myaliv://topup-callback?status=failed&message=Declined&...
```

The cubit treats `status == "success"` or `status == "completed"` (case-insensitive) as `PaymentSuccess`; anything else becomes `PaymentFailure`.

---

## State Machine

```
initial → loading → ready → success
                  ↘ failure
```

| Status    | Screen shows             |
|-----------|--------------------------|
| `initial` | `SizedBox.shrink()`      |
| `loading` | `PaymentShimmerWidget`   |
| `ready`   | `PaymentWebViewWidget`   |
| `success` | `onSuccess` callback fires |
| `failure` | `_ErrorView` + `onFailure` callback fires |

---

## Shimmer Loading

Two-phase shimmer:

1. **API call phase** — `isLoading` state shows `PaymentShimmerWidget` full-screen.
2. **WebView render phase** — `PaymentWebViewWidget` uses a `Stack`:
   - WebView loads HTML behind the shimmer.
   - `AnimatedOpacity` shimmer overlay fades out (400 ms) when `onPageFinished` fires.

The shimmer mimics a typical PowerTranz card-entry page: provider logo, card number field, expiry + CVV row, cardholder name, order summary, pay button, security badges.

---

## Dependency Injection

### Registration

`payment_iframe_injection.dart` registers three services with GetIt:

```dart
Future<void> setupPaymentIFrameInjection() async {
  instance.registerLazySingleton<PaymentIFrameApiService>(...);
  instance.registerLazySingleton<PaymentIFrameRepository>(...);
  // factory = fresh Cubit per screen instance (stateful)
  instance.registerFactory<PaymentIFrameCubit>(...);
}
```

### App-level wiring

Call in `main_injection_container.dart`:

```dart
await setupPaymentIFrameInjection();
```

### Screen usage

`PaymentIFrameScreen` calls `instance<PaymentIFrameCubit>()` inside its own `BlocProvider.create` so each push of the screen gets a fresh Cubit:

```dart
BlocProvider(
  create: (_) => instance<PaymentIFrameCubit>()..initiate(request),
  child: _PaymentIFrameView(...),
)
```

---

## Platform Configuration

### Android — `android/app/src/main/AndroidManifest.xml`

Add inside `<activity>`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="myaliv"/>
</intent-filter>
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myaliv</string>
        </array>
    </dict>
</array>
```

### Main app pubspec.yaml

`webview_flutter` **must** be a direct dependency of the main app — transitive via this package is not enough for Android native plugin registration:

```yaml
dependencies:
  payment_iframe:
    path: packages/feartures/payment_iframe
  webview_flutter: ^4.10.0   # required for native WebView registration
```

---

## Adding a New Payment Flow

1. Add an API endpoint constant in `lib/core/networkService/api_paths.dart`.
2. Push `PaymentIFrameScreen` from your feature screen with the new `PaymentRequest`.
3. If the endpoint requires auth, set `requiresAuth: true`.
4. Handle `onSuccess` (navigate to receipt) and `onFailure` (or leave empty to use `_ErrorView`).

No changes to the package itself are needed — it is endpoint-agnostic.

---

## Troubleshooting

### 401 on guest endpoint

**Symptom**: `❌ ERROR [401] POST .../Guest/top-up — Session expired`

**Cause**: `BearerAuthInterceptor` injects a `Bearer` token on every request; guest endpoint rejects authenticated requests.

**Fix**: Set `requiresAuth: false` on `PaymentRequest` (this is the default). The service passes `Options(extra: {'skipAuth': true})` which the interceptor checks before injecting the token.

---

### WebView platform not registered (Android crash)

**Symptom**: `java.lang.IllegalStateException: Trying to create a platform view of unregistered type: plugins.flutter.io/webview`

**Cause**: Android native plugins must be a direct dependency of the host app — a transitive dep from a sub-package is not registered by the Flutter build system.

**Fix**:
1. Add `webview_flutter: ^4.10.0` to the **main app's** `pubspec.yaml`.
2. Run a full rebuild — hot restart is not enough:
   ```bash
   flutter clean && flutter pub get && flutter run
   ```

---

### DefaultAppBar is not a PreferredSizeWidget

**Symptom**: `The argument type 'DefaultAppBar' can't be assigned to 'PreferredSizeWidget?'`

**Fix**: Wrap it:
```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(64),
  child: DefaultAppBar(title: '...'),
),
```
