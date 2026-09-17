# MyAliv — CI/CD Setup Guide

## Project Context

| Property | Value |
|---|---|
| App name | MyAliv (MyALIV) |
| Flutter version | 3.10.1+ |
| Current app version | 3.0.2+11 |
| Android app ID | `org.app.myaliv` |
| Android namespace | `com.example.myaliv_mobile_app` ← needs fixing (see Pre-flight) |
| iOS bundle ID | Set via Xcode (not yet configured for CI) |
| Firebase | Already integrated (`firebase_core`, `firebase_analytics`) |
| Current CI | `.github/workflows/flutter_ci.yml` — runs analyze + test only |

---

## Pre-flight Fix (Do This First)

### Fix Android namespace / applicationId mismatch

`android/app/build.gradle.kts` currently has:
```kotlin
namespace = "com.example.myaliv_mobile_app"   // ← placeholder
applicationId = "org.app.myaliv"              // ← real ID
```

The namespace should match the applicationId. Fix it before setting up any signing or Firebase, or you will get mismatched app entries in Google Play and Firebase consoles.

```kotlin
// android/app/build.gradle.kts
android {
    namespace = "org.app.myaliv"   // ← match applicationId
    ...
    defaultConfig {
        applicationId = "org.app.myaliv"
        ...
    }
}
```

Also update your Java/Kotlin source package structure if it references `com.example.myaliv_mobile_app`.

---

## Branch → Environment Map

| Branch pattern | Environment | Android output | iOS output |
|---|---|---|---|
| `develop` | dev | Debug APK → Firebase App Distribution | Unsigned (build check only) |
| `release/**`, `hotfix/**` | staging | Signed APK → Firebase App Distribution | AdHoc IPA → Firebase App Distribution |
| `main` | production | Signed AAB → Play Store (internal track) | IPA → TestFlight |

---

## Implementation Phases

```
Phase 1 — Build Verification          (no secrets, 1–2 days)
Phase 2 — Android Signing + Firebase  (4 secrets, 2–3 days)
Phase 3 — iOS Fastlane + TestFlight   (8 secrets, 3–5 days)
Phase 4 — Store Production Deploy     (Play Store + App Store, 1–2 days)
```

---

## Phase 1 — Build Verification

**Goal:** Prove the app compiles on CI for both platforms on every push. No signing. No testers. Just catch broken builds early.

### What to add to `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: ["develop"]
  pull_request:

env:
  FLUTTER_VERSION: "3.47.4"   # pin to your actual version

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --fatal-infos --fatal-warnings

      - name: Format check
        run: dart format --output=none --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Check coverage threshold (70%)
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -o '[0-9.]*%' | head -1 | tr -d '%')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 70" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 70% threshold"
            exit 1
          fi

  build-android-debug:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Install dependencies
        run: flutter pub get

      - name: Build debug APK
        run: flutter build apk --debug

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk

  build-ios-check:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build iOS (no codesign)
        run: flutter build ios --no-codesign --debug
```

**Result:** Every PR and every push to `develop` runs analyze → test → builds both platforms. Broken builds are caught before anyone reviews the PR.

---

## Phase 2 — Android Signing + Firebase App Distribution

**Goal:** Testers automatically receive a download link after every merge to `develop`. No manual APK sharing.

### Step 2.1 — Create a release keystore (run once locally)

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

**Store the passwords somewhere safe** (e.g. 1Password). You will need them for secrets.

Base64-encode the keystore for GitHub:
```bash
base64 -i upload-keystore.jks | pbcopy   # macOS — copies to clipboard
# or
base64 -i upload-keystore.jks > keystore.b64  # Linux
```

**Never commit `upload-keystore.jks` to git.** Add it to `.gitignore`:
```
/upload-keystore.jks
/android/key.properties
```

### Step 2.2 — Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**:

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | Output of `base64 -i upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Password you chose in keytool |
| `KEY_ALIAS` | `upload` (or whatever alias you used) |
| `KEY_PASSWORD` | Key password (can be same as keystore password) |
| `FIREBASE_TOKEN` | Run `firebase login:ci` on your machine |
| `FIREBASE_ANDROID_APP_ID` | Firebase Console → your Android app → App ID (looks like `1:123456:android:abc`) |

### Step 2.3 — Create `android/key.properties`

This file is gitignored and read by Gradle during local builds. For CI, the workflow writes it dynamically.

```properties
# android/key.properties  (add to .gitignore)
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Step 2.4 — Update `android/app/build.gradle.kts`

```kotlin
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load signing properties from key.properties (local) or env (CI)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "org.app.myaliv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: System.getenv("KEY_ALIAS")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: System.getenv("KEY_PASSWORD")
            storeFile = (keystoreProperties["storeFile"] as String?
                ?: System.getenv("KEYSTORE_FILE"))?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
                ?: System.getenv("KEYSTORE_PASSWORD")
        }
    }

    defaultConfig {
        applicationId = "org.app.myaliv"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}
```

### Step 2.5 — Install Firebase CLI tools for CI

Add to your project root:
```bash
npm install -g firebase-tools
# or use the action in the workflow
```

### Step 2.6 — Full workflow with Android signing + Firebase distribution

Replace `.github/workflows/flutter_ci.yml` with:

```yaml
name: Flutter CI/CD

on:
  push:
    branches: ["develop", "release/**", "hotfix/**", "main"]
  pull_request:

env:
  FLUTTER_VERSION: "3.47.4"
  JAVA_VERSION: "17"

jobs:
  # ─── Analyze ──────────────────────────────────────────────────────
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze --fatal-infos --fatal-warnings
      - run: dart format --output=none --set-exit-if-changed .

  # ─── Test ─────────────────────────────────────────────────────────
  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter test --coverage
      - name: Check 70% coverage threshold
        run: |
          sudo apt-get install -y lcov
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 \
            | grep "lines" | grep -o '[0-9.]*%' | head -1 | tr -d '%')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 70" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% < 70%"
            exit 1
          fi
          echo "✅ Coverage $COVERAGE%"

  # ─── Build & Deploy Android ───────────────────────────────────────
  build-android:
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push'
    outputs:
      environment: ${{ steps.env.outputs.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=production" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == refs/heads/release/* ]] || \
               [[ "${{ github.ref }}" == refs/heads/hotfix/* ]]; then
            echo "environment=staging" >> $GITHUB_OUTPUT
          else
            echo "environment=dev" >> $GITHUB_OUTPUT
          fi

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: ${{ env.JAVA_VERSION }}

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - run: flutter pub get

      # Write keystore from secret
      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/upload-keystore.jks

      # Write key.properties for Gradle
      - name: Write key.properties
        run: |
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      # Production → AAB for Play Store
      - name: Build release AAB (production)
        if: steps.env.outputs.environment == 'production'
        run: flutter build appbundle --release

      # Staging / dev → signed APK for Firebase Distribution
      - name: Build release APK (staging/dev)
        if: steps.env.outputs.environment != 'production'
        run: flutter build apk --release

      - name: Upload APK artifact
        if: steps.env.outputs.environment != 'production'
        uses: actions/upload-artifact@v4
        with:
          name: release-apk-${{ steps.env.outputs.environment }}
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Upload AAB artifact
        if: steps.env.outputs.environment == 'production'
        uses: actions/upload-artifact@v4
        with:
          name: release-aab-production
          path: build/app/outputs/bundle/release/app-release.aab

      # Deploy to Firebase App Distribution (dev + staging only)
      - name: Deploy to Firebase App Distribution
        if: steps.env.outputs.environment != 'production'
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk
          releaseNotes: |
            Branch: ${{ github.ref_name }}
            Commit: ${{ github.sha }}
            ${{ github.event.head_commit.message }}

  # ─── Build iOS (check only on PRs, full build on push) ────────────
  build-ios:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - name: Build iOS (no codesign)
        run: flutter build ios --no-codesign --release
```

### Step 2.7 — Firebase App Distribution setup

1. Go to [Firebase Console](https://console.firebase.google.com) → your MyAliv project
2. Navigate to **App Distribution** (under Release & Monitor)
3. Create a tester group named **`testers`** and add email addresses
4. Testers get an email invite and then receive a link for every new build automatically

---

## Phase 3 — iOS Fastlane + TestFlight

**Goal:** Signed IPA built on CI and uploaded to TestFlight after every push to `release/**`.

**Prerequisites:** Apple Developer account ($99/year), app created in App Store Connect.

### Step 3.1 — Install Fastlane locally

```bash
# In the ios/ directory
cd ios
bundle init
```

Add to `ios/Gemfile`:
```ruby
source "https://rubygems.org"

gem "fastlane"
gem "match"
```

```bash
bundle install
```

### Step 3.2 — Create a private certs repository

Create a new **private** GitHub repo (e.g. `org/myaliv-certs`). Fastlane Match will store all certificates and provisioning profiles there, encrypted.

### Step 3.3 — Create `ios/fastlane/Appfile`

```ruby
# ios/fastlane/Appfile
app_identifier("org.app.myaliv")
apple_id("your-apple-id@email.com")
team_id(ENV["APPLE_TEAM_ID"])
```

### Step 3.4 — Create `ios/fastlane/Matchfile`

```ruby
# ios/fastlane/Matchfile
git_url(ENV["MATCH_GIT_URL"])
storage_mode("git")
type("appstore")            # default — override per lane
app_identifier(["org.app.myaliv"])
username("your-apple-id@email.com")
```

### Step 3.5 — Bootstrap certificates (run once locally)

```bash
cd ios

# Development
bundle exec fastlane match development --app_identifier org.app.myaliv

# AdHoc (for staging Firebase Distribution)
bundle exec fastlane match adhoc --app_identifier org.app.myaliv

# App Store (for TestFlight/production)
bundle exec fastlane match appstore --app_identifier org.app.myaliv
```

This pushes encrypted certs to your private certs repo. Every CI run pulls and decrypts them using `MATCH_PASSWORD`.

### Step 3.6 — Create `ios/fastlane/Fastfile`

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do

  desc "Build and upload to TestFlight"
  lane :release do
    setup_ci if ENV["CI"]

    match(
      type: "appstore",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
      app_identifier: "org.app.myaliv",
    )

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "./build",
      output_name: "MyAliv.ipa",
    )

    upload_to_testflight(
      api_key_path: "AuthKey.p8",
      skip_waiting_for_build_processing: true,
      changelog: ENV["RELEASE_NOTES"] || "No release notes",
    )
  end

  desc "Build AdHoc IPA for Firebase Distribution (staging)"
  lane :staging do
    setup_ci if ENV["CI"]

    match(
      type: "adhoc",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
      app_identifier: "org.app.myaliv",
    )

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "ad-hoc",
      output_directory: "./build",
      output_name: "MyAliv-staging.ipa",
    )
  end

end
```

### Step 3.7 — Add App Store Connect API Key secrets

Go to [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Integrations → Keys → Generate API Key.

| Secret name | How to get it |
|---|---|
| `APPLE_API_KEY_ID` | Key ID shown in App Store Connect |
| `APPLE_API_ISSUER_ID` | Issuer ID shown on the same page |
| `APPLE_API_KEY_BASE64` | `base64 -i AuthKey_XXXX.p8` |
| `APPLE_TEAM_ID` | developer.apple.com → Membership |
| `MATCH_GIT_URL` | SSH URL of your private certs repo (e.g. `git@github.com:org/myaliv-certs.git`) |
| `MATCH_PASSWORD` | The passphrase you chose when running `fastlane match` |

### Step 3.8 — Add iOS job to the workflow

Add this job to `flutter_ci_cd.yml`:

```yaml
  build-ios-release:
    runs-on: macos-latest
    needs: test
    if: |
      github.event_name == 'push' &&
      (startsWith(github.ref, 'refs/heads/release/') ||
       startsWith(github.ref, 'refs/heads/hotfix/') ||
       github.ref == 'refs/heads/main')
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - run: flutter pub get

      - name: Build iOS archive
        run: flutter build ios --release --no-codesign

      - name: Set up SSH for Match
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.MATCH_SSH_PRIVATE_KEY }}

      - name: Write App Store Connect API key
        run: |
          echo "${{ secrets.APPLE_API_KEY_BASE64 }}" | base64 --decode > ios/AuthKey.p8

      - name: Install Fastlane gems
        working-directory: ios
        run: bundle install

      - name: Run Fastlane (staging → staging lane, main → release lane)
        working-directory: ios
        env:
          APPLE_API_KEY_ID: ${{ secrets.APPLE_API_KEY_ID }}
          APPLE_API_ISSUER_ID: ${{ secrets.APPLE_API_ISSUER_ID }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          RELEASE_NOTES: ${{ github.event.head_commit.message }}
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            bundle exec fastlane release
          else
            bundle exec fastlane staging
          fi
```

---

## Phase 4 — Production Store Deployment

**Goal:** Push to `main` triggers a Play Store internal track upload (Android) and TestFlight (iOS).

### Step 4.1 — Google Play Store API key

1. Go to [Google Play Console](https://play.google.com/console) → Setup → API access
2. Link to a Google Cloud project
3. Create a service account with **Release Manager** role
4. Download the JSON key

| Secret name | Value |
|---|---|
| `PLAY_STORE_JSON_KEY` | Contents of the downloaded JSON key file |

### Step 4.2 — Add Android Fastfile

Create `android/fastlane/Fastfile`:

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do

  desc "Upload AAB to Play Store internal track"
  lane :production do
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key_data: ENV["PLAY_STORE_JSON_KEY"],
      package_name: "org.app.myaliv",
      skip_upload_apk: true,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end

end
```

### Step 4.3 — Add production deploy step to the workflow

In the `build-android` job, after the AAB is built, add:

```yaml
      - name: Install Fastlane (Android)
        if: steps.env.outputs.environment == 'production'
        working-directory: android
        run: |
          bundle install

      - name: Deploy to Play Store internal track
        if: steps.env.outputs.environment == 'production'
        working-directory: android
        env:
          PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}
        run: bundle exec fastlane production
```

### Step 4.4 — GitHub Environments for production gate

In **Settings → Environments**, create three environments: `dev`, `staging`, `production`.

For the `production` environment:
- Add **Required reviewers** — at least one person must approve before the deploy job runs
- Set **Deployment branches** → restrict to `main`

Then add `environment: production` to your production deploy job:

```yaml
  deploy-production:
    runs-on: ubuntu-latest
    needs: build-android
    environment: production       # ← triggers approval gate
    if: github.ref == 'refs/heads/main'
    steps:
      # deploy steps here
```

---

## Secrets Summary

All secrets added in **Settings → Secrets and variables → Actions**:

### Phase 2 (Android + Firebase)
| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | `base64 -i upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Password chosen in keytool |
| `KEY_ALIAS` | Alias (e.g. `upload`) |
| `KEY_PASSWORD` | Key password |
| `FIREBASE_TOKEN` | `firebase login:ci` |
| `FIREBASE_ANDROID_APP_ID` | Firebase Console → Android app → App ID |

### Phase 3 (iOS + TestFlight)
| Secret | Description |
|---|---|
| `APPLE_API_KEY_ID` | App Store Connect → Keys → Key ID |
| `APPLE_API_ISSUER_ID` | App Store Connect → Keys → Issuer ID |
| `APPLE_API_KEY_BASE64` | `base64 -i AuthKey_XXXX.p8` |
| `APPLE_TEAM_ID` | developer.apple.com → Membership |
| `MATCH_GIT_URL` | SSH URL of your private certs repo |
| `MATCH_PASSWORD` | Passphrase used when running `fastlane match` |
| `MATCH_SSH_PRIVATE_KEY` | Private key that has read access to the certs repo |

### Phase 4 (Play Store)
| Secret | Description |
|---|---|
| `PLAY_STORE_JSON_KEY` | Contents of service account JSON from Google Play Console |

---

## Files to Add to `.gitignore`

```gitignore
# Signing
/upload-keystore.jks
/android/key.properties
/android/upload-keystore.jks
/ios/AuthKey.p8

# Fastlane
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots/**
**/fastlane/test_output
```

---

## Local Development Checks

Run these before every push to catch issues the CI will reject:

```bash
# 1. Format
dart format --output=none --set-exit-if-changed .

# 2. Analyze
flutter analyze --fatal-infos --fatal-warnings

# 3. Tests with coverage
flutter test --coverage

# 4. Build debug APK locally
flutter build apk --debug

# 5. Build iOS no-codesign
flutter build ios --no-codesign
```

---

## Troubleshooting

### `flutter analyze` fails on generated files

Add to `analysis_options.yaml`:
```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
```

### Gradle signing error on CI

Verify the keystore decodes correctly:
```bash
echo "$KEYSTORE_BASE64" | base64 --decode | file -
# Expected: Java KeyStore
```

### Match can't clone the certs repo

The runner needs SSH access to your certs repo. In the certs repo settings → Deploy keys, add the public key matching `MATCH_SSH_PRIVATE_KEY`. Alternatively switch Match to HTTPS with a fine-grained GitHub personal access token and set `git_url` to the HTTPS URL.

### iOS build timeout (60 min limit)

CocoaPods resolution is the usual cause. Ensure `ios/Podfile.lock` is committed so the cache restores correctly instead of resolving from scratch.

### Firebase App Distribution: tester group not found

Create the group in Firebase Console → App Distribution → Testers & Groups before the first CI run. The `groups: testers` field in the action must match exactly.

### Coverage threshold always failing

If you have no tests yet, coverage will be 0%. Either lower the threshold temporarily or add a placeholder test. The `test/widget_test.dart` added earlier ensures at least one test runs.

---

## Rollout Order

```
Week 1:
  ✅ Fix namespace/applicationId mismatch
  ✅ Phase 1 — build verification on every PR

Week 2:
  □ Create keystore + add signing to Gradle
  □ Set up Firebase App Distribution group
  □ Phase 2 — signed APK auto-delivered to testers on develop merge

Week 3–4:
  □ Apple Developer setup + App Store Connect app created
  □ Bootstrap Fastlane Match
  □ Phase 3 — IPA to TestFlight on release/** merge

Month 2:
  □ Play Store app created + service account
  □ Phase 4 — AAB to Play Store internal track on main merge
  □ Add production approval gate in GitHub Environments
```
