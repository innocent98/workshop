# Workchop (mobile)

Workchop is a Nigerian artisan-booking marketplace. **Clients** find nearby
artisans (plumbers, electricians, ...), book them instantly or on a schedule,
negotiate the price, pay through Paystack escrow and confirm (or dispute) the
finished job. **Artisans** accept jobs, log progress, get paid into a wallet and
withdraw to a bank account. Artisans can verify their identity (NIN + selfie,
checked by Dojah on the backend) to earn a trust badge.

This repository is the Flutter app (Android + iOS). The FastAPI backend lives in
the separate `workshop-backend` repository.

## Stack

| Concern | Choice |
| --- | --- |
| UI | Flutter 3 (Dart `^3.8.1`), Material, `flutter_screenutil` |
| State | Riverpod 3 (`AsyncNotifierProvider` / `FutureProvider`) |
| Routing | `go_router` (`lib/core/routes/app_router.dart`) |
| HTTP | Dio singleton (`DioClient().dio`) + auth interceptor; 401 triggers forced logout |
| Auth/Push | Firebase Auth (Google sign-in), Firebase Messaging, `flutter_local_notifications` |
| Storage | `flutter_secure_storage` (tokens), `shared_preferences` (non-sensitive flags) |

## Architecture

Feature-first clean architecture. Each feature under `lib/features/<feature>/` has up to three layers:

```
lib/
  main.dart                  App entry, Firebase init, forced-logout listener
  core/
    config/                  api_config.dart  (build-time env: API_BASE_URL, APP_ENV)
    network/                 Dio client, auth interceptor, ApiException types
    providers/               app-wide Riverpod providers (auth, location, ...)
    routes/                  go_router configuration
    services/                token storage, push, location, onboarding, session
    utils/                   validators, image compressor, phone launcher
    widgets/ theme/ constants/   shared UI building blocks
  features/<feature>/
    domain/                  models + repository interfaces (pure Dart)
    data/                    request/response models, datasources (Dio), repository impls
    presentation/            pages, widgets, Riverpod providers
```

Rules of thumb: never construct `Dio` directly (use `DioClient().dio`); API
JSON is snake_case and decimals arrive as strings, so response models convert
to camelCase domain objects and parse money with `double.tryParse`; datasources
catch `DioException` and rethrow as `ApiException` / `NetworkException` /
`UnauthorizedException`.

## Running the app

Prerequisites: Flutter stable (see `pubspec.yaml` for the Dart SDK floor), Xcode
for iOS, Android Studio / SDK for Android. Firebase config files
(`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) are
already in the repo for the project's Firebase app.

```bash
flutter pub get
```

### Environment defines

All environment configuration is passed with `--dart-define` and is **baked into
the binary, so it must never contain secrets**.

| Define | Default | Meaning |
| --- | --- | --- |
| `API_BASE_URL` | `https://api.workchop.example/api/v1` (placeholder) | API root including `/api/v1`, no trailing slash |
| `APP_ENV` | `prod` | `dev`, `staging` or `prod`. Non-prod enables request logging (URL/status only, never bodies) |

The default is a placeholder: a build without `API_BASE_URL` will not reach a
real backend. Always pass it explicitly.

### Dev (local backend)

The iOS simulator reaches the host machine on `localhost`; the Android emulator
needs `10.0.2.2`.

```bash
# iOS simulator
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# Android emulator
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# Physical device through a tunnel (ngrok etc.)
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=https://<your-tunnel>/api/v1
```

### Staging

```bash
flutter run   --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging-api.<your-domain>/api/v1
flutter build apk --release --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging-api.<your-domain>/api/v1
```

### Production

```bash
# Android Play Store bundle (needs android/key.properties, see docs/sop/release-prep.md)
flutter build appbundle --release \
  --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.<your-domain>/api/v1

# iOS (then archive/upload from Xcode)
flutter build ipa --release \
  --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.<your-domain>/api/v1
```

Release prep (signing, icons, iOS capabilities) is documented in
[`docs/sop/release-prep.md`](docs/sop/release-prep.md).

## Quality checks

CI (`.github/workflows/ci.yml`) runs these on every PR that touches code:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Tests are hermetic (no network, no Firebase); repository tests stub Dio with a
fake `HttpClientAdapter`.

## Docs

- `docs/sop/` - one record per shipped change (what, why, how, how to roll back)
- `docs/checklist/` - the living build checklist
- `docs/api_docs/`, `docs/frontend-api-documentation.md` - backend API reference (may lag the backend)
