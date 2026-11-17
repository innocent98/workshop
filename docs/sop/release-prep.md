# SOP: Release preparation (Android + iOS)

**What shipped:** everything that can be prepared without the owner's signing certificates: Android release signing wiring, R8/shrinking, versioning from `pubspec.yaml`, launcher-icon config, Crashlytics, iOS permission macros, and the iOS/Play Store checklist below. PR: see `docs/sop/mobile-stabilisation.md`.

## Android

| Item | State |
| --- | --- |
| `applicationId` | `com.workchop.workchop` (unchanged; matches `google-services.json`). Changing it later means a new Firebase app + Play listing. |
| Version | `versionCode`/`versionName` now come from `version:` in `pubspec.yaml` (currently `1.0.0+1`). Bump the `+N` for every Play upload. |
| Release signing | `android/app/build.gradle.kts` reads `android/key.properties` (gitignored; template `android/key.properties.example`). If the file is absent it **falls back to the debug key** so CI/`flutter run --release` work. Such a build must never be uploaded. |
| R8 / shrink | `isMinifyEnabled` + `isShrinkResources` on for release, rules in `android/app/proguard-rules.pro`. Not run locally (policy); the CI job `android-release-build` compiles it. First real check: install the CI/`flutter build appbundle` artifact and exercise login, booking, push and the camera. |
| Crashlytics | `firebase_crashlytics` + Gradle plugin `com.google.firebase.crashlytics` 3.0.2; Dart handlers in `lib/main.dart`; collection disabled in debug. Needs no certificates. |
| Launcher icon | `flutter_launcher_icons` configured in `pubspec.yaml`, but **no logo asset exists in the repo**. Drop a 1024x1024 PNG at `assets/branding/app_icon.png` (+ `app_icon_foreground.png` for the adaptive icon) and run `dart run flutter_launcher_icons`. |
| App label | Fixed to `Workchop` (was `workchop`). |

### Create the upload key (owner, one time)

```bash
keytool -genkey -v -keystore ~/keys/workchop-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # then fill it in
flutter build appbundle --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.<domain>/api/v1
```

Enrol in Play App Signing; keep the upload key backed up outside the repo.

## iOS (no signing files were touched)

Bundle id and team come from Xcode; the owner must set them under *Signing & Capabilities*.

| Capability / setting | Needed? | Notes |
| --- | --- | --- |
| Push Notifications | **Yes** | `firebase_messaging` + local notifications. Enable the capability and create an APNs auth key (.p8) in Apple Developer, upload it in Firebase Console > Cloud Messaging. |
| Background Modes > Remote notifications | **Yes** | For silent/background FCM. |
| Location (when in use) | Yes | Usage strings already in `Info.plist`. `NSLocationAlwaysAndWhenInUse...` is present but the app only needs *when in use*; consider removing it to ease App Review. |
| Camera / Photo library | Yes | Usage strings present (profile photo, portfolio, progress photos, identity selfie). Text is generic; make it specific for review ("take a selfie to verify your identity"). |
| Sign in with Google | Yes (URL scheme) | `GoogleService-Info.plist` present; `REVERSED_CLIENT_ID` must be registered as a URL scheme in `Info.plist` for Google sign-in to return to the app. **Verify this on a device**; it is not in `Info.plist` today. |
| **Sign in with Apple** | **Required by App Store Review Guideline 4.8 if Google sign-in is offered as a *login* option** | The app offers "Continue with Google" on the login page. Apple requires an equivalent privacy-preserving option (Sign in with Apple) unless the login is limited to your own account system. Either add Sign in with Apple (capability + `sign_in_with_apple` + a backend endpoint verifying Apple identity tokens) or remove Google sign-in on iOS. Backend currently has only `google` sign-in. Decision for the owner. |
| Associated domains / Universal links | No | Not used. Payment returns rely on app resume, not deep links. |
| In-App Purchase | No | Services are paid through Paystack (physical-world services are exempt from IAP). |
| Minimum iOS version | **15.0** (raised from 13.0: Xcode 26/27 refuses lower pod targets). `Podfile` forces pods to >= 15.0. |
| `PERMISSION_*` macros | Done | `ios/Podfile` now defines `PERMISSION_CAMERA/LOCATION/PHOTOS/NOTIFICATIONS=1`; without them `permission_handler` reported "denied" without prompting. Run `cd ios && pod install` after pulling. |
| Crashlytics dSYM upload | **Not done** | Needs an Xcode Run Script build phase (`Pods/FirebaseCrashlytics/run`); edits `project.pbxproj`, so left for the owner (crashes are reported but unsymbolicated until added). |
| Export compliance | Set `ITSAppUsesNonExemptEncryption=false` in `Info.plist` if only HTTPS is used. |

## Store listing prerequisites (owner)
Privacy policy URL and terms (Dojah NIN + selfie, location, payments), support URL, screenshots (see `screenshots/`), data-safety / privacy-nutrition answers (collects: name, email, phone, location, photos, government ID number + selfie via Dojah, payment references).

## Operate / roll back
Everything here is configuration. Roll back by reverting the PR; no data or API depends on it. Crashlytics can be turned off at runtime by changing `setCrashlyticsCollectionEnabled`.
