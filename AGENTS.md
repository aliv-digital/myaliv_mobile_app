# AGENTS.md — MYALIV Flutter Repository

## Scope

These instructions apply to the entire repository unless a more specific
`AGENTS.md` exists in a subdirectory.

This is the MYALIV Flutter mobile application. Preserve the established
architecture and behavior. Treat nearby, working features as the primary
reference for new implementation.

## Before Editing

Before making changes:

1. Run `git branch --show-current`.
2. Run `git status --short --branch`.
3. Run `git remote -v`.
4. Inspect `pubspec.yaml` and `analysis_options.yaml`.
5. Identify any pre-existing uncommitted changes and do not overwrite them.
6. Find the closest equivalent feature, including the same prepaid, postpaid,
   guest, home, payment, or receipt flow.
7. Read that feature's view, widgets, Bloc/Cubit, repository, models, theme,
   route registration, dependency injection, and tests.

Do not modify unrelated code or generated files.

## Toolchain

The repository currently targets:

- Flutter stable
- Dart `>=3.10.0 <4.0.0`
- Material 3
- Android Java/Kotlin 17
- iOS 15.0+

Use the repository's pinned dependency constraints and lockfile. Do not upgrade
Flutter, Dart, CocoaPods, Gradle, Kotlin, or package versions unless the task
explicitly requires it.

## Project Structure

Important locations:

- `lib/main.dart`: application startup and root providers.
- `lib/main_injection_container.dart`: app dependency registration.
- `lib/router/app_router.dart`: central GoRouter configuration.
- `lib/router/app_routes.dart`: route path constants.
- `lib/app/`: application features.
- `lib/app/Aliv-Mobile/`: authenticated subscriber flows.
- `lib/app/Aliv-Mobile-Guest/`: guest flows.
- `lib/app/Home/`: authenticated home modules.
- `lib/app/Plans/`: plan browsing and purchase flows.
- `lib/app/common/`: cross-feature application services.
- `lib/core/`: legacy/app-specific core utilities.
- `lib/resources/`: shared widgets and visual constants.
- `packages/core/`: preferred shared network, auth, DI, analytics, and time layer.
- `packages/feartures/finger_face_security/`: biometric package. Preserve the
  existing misspelled path unless a dedicated migration is requested.
- `test/`: unit, model, Bloc, and Cubit tests.

## Feature Architecture

Use a feature-first structure matching nearby mature features:

```text
feature/
  bloc/ or cubit/
  models/ or model/
  repository/
    services/
  theme/
  view/
  widgets/
  feature_injection.dart
```

Do not reorganize an existing feature merely to match this outline.

Preferred dependency direction:

```text
view/widgets -> Bloc or Cubit -> repository -> API/parser service
             -> packages/core NetworkService
```

Rules:

- UI widgets must not make backend requests directly.
- BLoCs/Cubits own state transitions and orchestration.
- Repositories define the feature's data operations.
- API services perform transport work.
- Parser services or model factories translate backend payloads.
- Models must represent external data explicitly and null-safely.
- Keep platform, network, and persistence details out of widgets.

## State Management

Use `flutter_bloc`.

Follow the closest feature:

- Use Bloc when the feature is event-driven and sibling flows use Bloc.
- Use Cubit for method-driven state where sibling features use Cubit.
- Use HydratedCubit/HydratedBloc only when state must survive app restarts.
- Use immutable states.
- Prefer a status enum with explicit initial/loading/success/empty/failure
  states.
- Provide `copyWith` and useful state getters.
- Use Equatable where the neighboring feature does.
- Map technical failures to user-facing messages in the Bloc/Cubit layer.
- Prevent duplicate in-flight requests where appropriate.
- Add an explicit reset/clear operation for authenticated cached state.

Short-lived feature BLoCs should normally be created at the screen boundary.
Shared singleton Cubits should be registered through GetIt and exposed with
`BlocProvider.value`.

Never create multiple owners for the same long-lived Bloc/Cubit instance.

## Dependency Injection

The repository uses GetIt through `package:core/core.dart`.

- Register core dependencies before app feature dependencies.
- Add feature registrations to `lib/main_injection_container.dart`.
- Prefer importing the canonical `instance` from `package:core/core.dart`.
- Do not declare or export another top-level `instance` symbol in new files.
- Avoid importing multiple injection files that expose identically named
  globals.
- Use `registerLazySingleton` for established shared services unless the
  neighboring feature requires another lifecycle.
- Use constructor injection for repositories, services, BLoCs, and Cubits.
- Do not hide required dependencies behind service-locator calls inside domain
  logic when constructor injection is practical.

## Networking and Authentication

Prefer `packages/core`:

- `NetworkService`
- `AuthManager`
- `BearerAuthInterceptor`
- shared network exception types
- secure token/session storage

Do not add another Dio or `http.Client` stack unless required for compatibility
with an existing feature.

When implementing API work:

1. Add paths to the established API path/constants location.
2. Use the shared authenticated `NetworkService`.
3. Use `skipAuth` only for actual unauthenticated endpoints.
4. Preserve the automatic refresh and hard-logout behavior.
5. Do not log tokens, passwords, card data, OTPs, or sensitive response bodies.
6. Convert network exceptions into repository- or feature-level failures.
7. Parse defensively because backend payload casing and shapes vary.
8. Keep request and response mapping covered by tests.

Legacy HTTP and feature-local Dio code may be maintained when necessary, but
new features should not extend those patterns without a documented reason.

## Models

Match the neighboring feature's conventions.

- Use immutable fields and `const` constructors where possible.
- Provide explicit `fromJson`/`toJson` methods for API and hydrated data.
- Handle optional fields and known backend variants safely.
- Use `copyWith` where mutation-like updates are needed.
- Implement reliable equality, preferably with Equatable when consistent with
  the feature.
- Keep wire-format names inside serialization code.
- Use enums for bounded backend concepts, with tolerant parsing.
- Do not pass raw JSON maps through UI layers.

## Navigation

Navigation uses GoRouter.

- Add path constants to `lib/router/app_routes.dart`.
- Register routes in `lib/router/app_router.dart`.
- Use `context.go`, `context.push`, or router methods consistently with the
  surrounding flow.
- Use typed route-argument classes for structured or required data.
- Use query parameters only for small, serializable, optional values.
- Avoid new untyped `Map` extras.
- Validate `state.extra` before casting.
- Do not add production fallback/demo customer data when route arguments are
  missing.
- Preserve the `ShellRoute` for authenticated bottom navigation.
- Account for biometric locking and hard logout when adding protected flows.
- Do not retain or use a `BuildContext` across an async gap without checking
  that it remains mounted.

The router is already large. Keep new route-building logic small and place
argument/data classes in the owning feature.

## UI and Design Conventions

MYALIV uses:

- Brand purple `#645D9C`.
- CircularPro typography.
- Material 3.
- SVG and raster assets under `assets/icons/` and `assets/images/`.
- Shared colors in `lib/resources/color_manager.dart`.
- Shared sizing in `lib/resources/size_manager.dart`.
- Shared widgets in `lib/resources/widgets/`.
- Feature-specific tokens in each feature's `theme/` directory.

Before creating a widget:

1. Search `lib/resources/widgets/`.
2. Search the owning feature's widgets.
3. Search similar prepaid, postpaid, guest, payment, and receipt flows.

Prefer existing components such as default buttons, app bars, input controls,
payment breakdown cards, receipt cards, card selectors, switches, striped
scaffolds, and toast helpers.

Do not introduce a new app-wide design system during an unrelated feature.
Do not duplicate colors or spacing when an established token exists.
Use feature-scoped theme constants for design-specific measurements that are
not broadly reusable.

Maintain visual parity with the nearest implemented design and test small and
large device layouts.

## Dart Style

For new code:

- Use `lower_case_with_underscores.dart` filenames.
- Use PascalCase for types and lowerCamelCase for members.
- Prefer package imports for cross-feature files and relative imports within a
  tightly scoped feature, matching neighboring code.
- Use `const` where valid.
- Use braces for control-flow statements.
- Use `debugPrint` rather than `print`.
- Guard verbose diagnostics with `kDebugMode`.
- Never commit secrets or sensitive debug logs.
- Avoid deprecated Flutter APIs in new code.
- Use `withValues(alpha: ...)` instead of `withOpacity`.
- Use `PopScope` for new back-navigation handling.
- Supply `key`/`super.key` on public widgets.
- Keep widgets small and extract repeated presentation into feature or shared
  widgets.
- Add comments for non-obvious business rules, not for self-evident code.

Do not rename legacy folders or files solely to satisfy naming lints; such
renames require a dedicated migration because of the import surface.

## Error and Loading Behavior

Every asynchronous feature should deliberately handle:

- Initial state.
- Loading state.
- Success state.
- Empty state where applicable.
- Validation failure.
- No-internet and timeout failures.
- Server/backend failures.
- Session expiry.
- Retry behavior where useful.
- Duplicate submission prevention.

Use the established toast, inline-error, skeleton, and loading-button patterns
from the nearest matching feature.

## Persistence and Logout

Authenticated state can exist in secure token storage, SharedPreferences,
HydratedBloc, cookies, and singleton Cubits.

When adding persistent authenticated data:

- Document its lifetime.
- Provide a clear/reset path.
- Add it to the hard-logout cleanup when required.
- Never persist passwords, OTPs, raw card data, or other secrets outside the
  existing approved secure-storage flow.
- Ensure one subscriber cannot see another subscriber's cached data.

## Testing

Use:

- `flutter_test`
- `bloc_test`
- `mocktail`

For behavior changes, add focused tests for:

- Model parsing and serialization.
- State equality and `copyWith`.
- Bloc/Cubit success, empty, validation, and error transitions.
- Cache and duplicate-request guards.
- Repository mapping and exception behavior.
- Important reusable widgets where practical.
- Navigation argument handling for complex flows.

Close BLoCs/Cubits in teardown and register mocktail fallback values when
needed. Avoid real network calls in unit tests.

## Required Validation

After Dart changes:

```bash
dart format <only-touched-dart-files>
flutter analyze
flutter test
```

Also run the relevant build when changing dependencies, platform configuration,
plugins, signing, permissions, or native integrations:

```bash
flutter build appbundle --release
flutter build ipa --release
```

If the repository already has analyzer failures unrelated to the task:

- Do not silently fix unrelated findings.
- Confirm that the change introduces no new findings.
- Report the baseline and remaining issues clearly.

Review `git status` and `git diff` after all tooling. Do not commit generated,
platform, signing, or lockfile changes unless they are intentional.

## Android

Current conventions:

- Application ID: `org.app.myaliv`
- Java/Kotlin target: 17
- Google Services plugin is enabled.
- Biometric, internet, and phone-call permissions are declared.

Do not change application IDs, namespace, SDK levels, signing, Gradle, Kotlin,
permissions, or Google Services configuration without explicit task scope.

Release signing must never use committed credentials. Do not add keystores,
passwords, service-account files, or signing secrets to Git.

## iOS

Current conventions:

- Bundle ID: `org.app.aliv`
- Minimum deployment target: iOS 15.0
- CocoaPods integration uses `use_frameworks!`.
- Face ID usage text is configured.

Do not change bundle IDs, development teams, signing profiles, deployment
target, entitlements, privacy descriptions, or Pod configuration without
explicit task scope.

Do not commit personal Xcode team changes unless requested.

## Firebase and Analytics

Firebase initialization is best-effort during local startup.

- Do not treat swallowed Firebase initialization errors as proof that a release
  is correctly configured.
- Preserve graceful local behavior.
- Validate required production configuration in the appropriate build/CI flow.
- Use the shared AnalyticsService rather than creating feature-local Firebase
  analytics clients.

## Git and Delivery

The repository uses:

- `main` for production-ready code.
- `develop` as the integration branch.
- Ticket branches using `<developer>/<ticket-name>`.
- Conventional Commit messages.

Do not commit directly to `main` or `develop`.
Do not commit, push, merge, rebase, or create a PR unless explicitly requested.
Do not discard or rewrite pre-existing user changes.
Keep feature work and broad cleanup in separate changes.

Before handoff, report:

- Files changed.
- Architecture decisions.
- Tests and commands run.
- Analyzer/test/build results.
- Known remaining issues.
- Any platform or configuration implications.

## Existing Technical Constraints

Be aware of these existing conditions:

- The central router is large.
- Legacy and current network stacks coexist.
- UI tokens are partly global and partly feature-scoped.
- Historical names do not consistently follow Dart naming rules.
- Several dependencies have newer incompatible versions.
- Android release signing and lint policy require dedicated production work.
- Root and core README documentation may be stale.

Do not use an unrelated feature task as an excuse for broad refactoring.
Prefer a focused implementation that matches the strongest existing patterns.
