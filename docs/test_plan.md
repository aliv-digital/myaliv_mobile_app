# Unit Test Plan — MyAliv Mobile App

## Scope

Three phased suites covering model equality, auth flow, and home screen plan loading.
Each suite is independently runnable and ordered by setup complexity.

---

## Test Structure

```
test/
├── models/
│   ├── login_state_test.dart
│   ├── login_otp_state_test.dart
│   ├── account_info_state_test.dart
│   ├── best_plan_model_test.dart
│   └── transaction_model_test.dart
├── auth/
│   ├── login_bloc_test.dart
│   └── login_otp_bloc_test.dart
└── home/
    └── best_plan_cubit_test.dart
```

---

## Suite 1 — Model Equality & Serialization

**No mocks required. Pure Dart.**

### 1.1 `LoginState` — `test/models/login_state_test.dart`

Source: `lib/app/Aliv-Mobile/login/bloc/auth_state.dart`

| Test | Assertion |
|---|---|
| Two identical states are equal | `state1 == state2` |
| States differing by one field are not equal | `state1 != state2` |
| `copyWith(phone: ...)` only changes phone | All other props unchanged |
| `copyWith()` with no args returns equal state | `state == state.copyWith()` |
| Initial state has `LoginStatus.initial` | `LoginState().status == LoginStatus.initial` |

### 1.2 `LoginOtpState` — `test/models/login_otp_state_test.dart`

Source: `lib/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart`

| Test | Assertion |
|---|---|
| Two identical states are equal | `state1 == state2` |
| `copyWith(code: '123456')` reflects new code | `state.code == '123456'` |
| Status transitions preserved in `copyWith` | `state.copyWith(status: loading).status == loading` |
| `errorType` defaults to `none` | `LoginOtpState().errorType == LoginOtpErrorType.none` |

### 1.3 `AccountInfoState` — `test/models/account_info_state_test.dart`

Source: `lib/app/Aliv-Mobile/account-information/cubit/account_info_state.dart`

| Test | Assertion |
|---|---|
| `hasAccount` is false when `accountInfo` is null | `state.hasAccount == false` |
| `hasAccount` is true when `accountInfo` is set | `state.hasAccount == true` |
| `isCacheStale()` returns true if `lastFetchedAt` is null | `state.isCacheStale() == true` |
| `isCacheStale()` returns false within TTL window | Timestamp within 24h → false |
| `isCacheStale()` returns true after TTL expires | Timestamp older than 24h → true |
| `cleared()` factory resets all fields | `status == initial`, `accountInfo == null` |
| Two states with same `accountInfo` are equal | `state1 == state2` |
| Computed getters (`email`, `fullName`) delegate to `accountInfo` | Match underlying model fields |

### 1.4 `BestPlanModel` — `test/models/best_plan_model_test.dart`

Source: `lib/app/Home/best-plans/models/best_plan_model.dart`

| Test | Assertion |
|---|---|
| `fromJson` parses all fields correctly | Each field matches fixture JSON |
| `toJson` round-trips back to same model | `BestPlanModel.fromJson(model.toJson()) == model` |
| `isExpired` is false when `expireOn` is today | Date-only comparison: today == expireOn → not expired |
| `isExpired` is true when `expireOn` is yesterday | Yesterday < today → expired |
| `isStarted` is false when `startFrom` is tomorrow | Tomorrow > today → not started |
| `isStarted` is true when `startFrom` is today | Today >= today → started |
| `copyWith(price: 99)` only changes price | Other fields unchanged |

**Fixture JSON:**
```dart
final planJson = {
  'id': 1,
  'price': '25.00',
  'planName': 'Summer Data',
  'subHeading': '10GB for 30 days',
  'link': 'https://example.com',
  'startFrom': '2026-01-01T00:00:00.000Z',
  'expireOn': '2026-12-31T00:00:00.000Z',
  'backgroundImageUrl': 'https://example.com/img.png',
  'type': 'prepaid',
  'status': 'active',
};
```

### 1.5 `TransactionModel` — `test/models/transaction_model_test.dart`

Source: `lib/app/Call-Logs/models/transaction_model.dart`

| Test | Assertion |
|---|---|
| Two identical instances are equal | `t1 == t2` |
| Instances differing by `amount` are not equal | `t1 != t2` |
| Null-safe fields (`promotion`, `reason`) accepted | No runtime error |

---

## Suite 2 — Auth Flow BLoC Tests

**Mocks: `LoginRepository`, `LoginOtpRepository`**

Dependencies to add:
```yaml
dev_dependencies:
  mocktail: ^1.0.4
  bloc_test: ^9.1.8
```

### 2.1 `LoginBloc` — `test/auth/login_bloc_test.dart`

Source: `lib/app/Aliv-Mobile/login/bloc/auth_bloc.dart`

**Mock:** `MockLoginRepository` via `mocktail`

#### Phone/Password field change events

| Test | Event | Expected State |
|---|---|---|
| Phone changed updates state | `LoginPhoneChanged('242-555-0001')` | `state.phone == '242-555-0001'` |
| Password changed updates state | `LoginPasswordChanged('secret')` | `state.password == 'secret'` |

#### `LoginSubmitted` — Happy paths

| Test | Repo stub | Expected states emitted |
|---|---|---|
| Direct login (no MFA) | Returns `LoginSuccess(ticket, accountId)` | `[loading, success(outcome: authenticated)]` |
| Login requires MFA | Returns `LoginMfaChallenge(mfaToken)` | `[loading, success(outcome: needsOtp)]` |

#### `LoginSubmitted` — Error paths

| Test | Repo stub / condition | Expected states |
|---|---|---|
| Invalid credentials | Throws with "invalid credentials" message | `[loading, failure(errorMessage: ...)]` |
| No internet | `NoInternetException` | `[loading, failure]` with network message |
| Empty phone field | No repo call | Emits field-level error, no loading state |
| Empty password field | No repo call | Emits field-level error, no loading state |

### 2.2 `LoginOtpBloc` — `test/auth/login_otp_bloc_test.dart`

Source: `lib/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart`

**Mock:** `MockLoginOtpRepository`, `MockAccountInfoCubit`, `MockAppUiConfigCubit`

#### `LoginOtpCodeChanged`

| Test | Event | Expected State |
|---|---|---|
| 6-char code accepted | `LoginOtpCodeChanged('123456')` | `state.code == '123456'` |

#### `LoginOtpSubmitted` — Happy path

| Test | Setup | Expected states |
|---|---|---|
| Valid OTP verified | Repo returns success, accountInfoCubit mocked | `[loading, success]` |

#### `LoginOtpSubmitted` — Error paths

| Test | Repo stub | Expected states |
|---|---|---|
| Wrong code | Returns invalid-code error | `[loading, failure(errorType: invalidCode)]` |
| Account locked | Returns lockout error | `[loading, failure(errorType: locked)]` |
| Network error | `NoInternetException` | `[loading, failure]` |

#### `LoginOtpResendRequested`

| Test | Repo stub | Expected states |
|---|---|---|
| Resend succeeds | Returns success | `[resendLoading, resendSuccess]` |
| Resend fails | Throws | `[resendLoading, resendFailure]` |

---

## Suite 3 — BestPlanCubit Tests

**Mock: `BestPlanRepository`**

Source: `lib/app/Home/best-plans/cubit/best_plan_cubit.dart`

File: `test/home/best_plan_cubit_test.dart`

### 3.1 Load plans — Happy paths

| Test | Setup | Expected states |
|---|---|---|
| Prepaid plans load successfully | Repo returns 3 prepaid plans | `[loading, loaded(plans: [...])]` |
| Postpaid plans load successfully | Repo returns 2 postpaid plans | `[loading, loaded(plans: [...])]` |
| No plans returned | Repo returns empty list | `[loading, empty]` |

### 3.2 Cache guard

| Test | Setup | Expected behavior |
|---|---|---|
| Second call within 5-min TTL skips fetch | Call `loadPlans` twice rapidly | Repo called exactly once |
| `forceRefresh: true` bypasses cache | Cache valid, force refresh | Repo called twice |
| Expired cache triggers re-fetch | Manipulate `lastFetchedAt` to 6 min ago | Repo called again |

### 3.3 Error paths

| Test | Repo stub | Expected states |
|---|---|---|
| Network timeout | `TimeoutException` | `[loading, failure(errorMessage: ...)]` |
| Parse failure | Throws `FormatException` | `[loading, failure]` |
| Generic server error | Throws `NetworkException` | `[loading, failure]` |

### 3.4 Duplicate load prevention

| Test | Setup | Expected behavior |
|---|---|---|
| `loadPlans` called while already loading | Call twice before first resolves | Repo called exactly once |

### 3.5 `reset()`

| Test | Expected |
|---|---|
| After loading, `reset()` returns to initial state | `state == BestPlanState.initial()` |

---

## Dependencies Required

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.8
  mocktail: ^1.0.4
```

---

## Mock Setup Pattern

```dart
// Example mock for BestPlanRepository
class MockBestPlanRepository extends Mock implements BestPlanRepository {}

void main() {
  late MockBestPlanRepository repository;
  late BestPlanCubit cubit;

  setUp(() {
    repository = MockBestPlanRepository();
    cubit = BestPlanCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  blocTest<BestPlanCubit, BestPlanState>(
    'emits [loading, loaded] when loadPlans succeeds',
    build: () {
      when(() => repository.fetchActivePlans('prepaid'))
          .thenAnswer((_) async => fakePrepaidPlans);
      return cubit;
    },
    act: (c) => c.loadPlans('prepaid'),
    expect: () => [
      isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
      isA<BestPlanState>().having((s) => s.isLoaded, 'isLoaded', true),
    ],
  );
}
```

---

## Implementation Order

| Phase | Suite | Effort | Value |
|---|---|---|---|
| 1 | Model equality + serialization | Low — no mocks | Catches regressions in data layer immediately |
| 2 | Auth BLoC tests | Medium — mock repos | Protects core user journey |
| 3 | BestPlanCubit tests | Medium — mock repos | Covers home screen plan loading + cache logic |
