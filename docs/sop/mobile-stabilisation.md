# SOP: Mobile stabilisation (branch `chore/mobile-stabilisation`)

**What shipped:** a single PR that removes the temporary ngrok URL, adds the missing client dispute-completion action, makes Paystack payment returns robust, deletes dead code and stubs, adds identity verification (Dojah hosted widget) on the artisan side, replaces the broken template test with a real hermetic suite, adds CI, Crashlytics and release prep. PR: see the PR for this branch (`gh pr view`).

## Why
The app was feature-complete on paper but not releasable: the API URL was a throwaway ngrok host, payments were confirmed by a single in-memory verify that was lost if the app was killed, clients had no way to dispute a job, raw `DioException` text reached users, mock data and dead buttons shipped, `test/widget_test.dart` was the failing counter template and there was no CI.

## How (decisions)

| Area | Decision | Rejected alternative |
| --- | --- | --- |
| API URL | `String.fromEnvironment('API_BASE_URL')` with a placeholder prod default, plus `APP_ENV` (`dev/staging/prod`). No flavors, no secrets in defines. | Gradle/Xcode flavors: much more native config for no gain at this stage. |
| Network logging | `LogInterceptor` now logs method/URL/status only, only in debug + non-prod. It used to log request/response bodies (passwords, NIN, tokens). | Keep bodies in dev: too easy to leak PII into shared logs. |
| Errors | `core/network/dio_error_mapper.dart` (`mapDioError`, `userMessage`, `isOfflineError`) is the single place that turns `DioException` into `ApiException` / `NetworkException` / `UnauthorizedException`; understands FastAPI `detail` as string, `{code,message}` and validation lists. `ApiException` gained an optional `code`. | Per-datasource copies (existed in payments/reviews). |
| Dispute completion | `PATCH /bookings/{id}/dispute-completion` body `{"dispute_reason": str}`; backend validates 10..500 chars, mirrored in `domain/dispute_rules.dart`. Button shown only when `canDisputeCompletion` (completed, not confirmed/disputed, before `completion_confirmation_deadline_at`). After success the list is re-fetched. Disputed bookings (backend status `disputed`) show a red "Disputed" banner with the reason on the ongoing card. | Optimistic local status: the server owns this state machine. |
| Payments | A `PaymentVerificationController` (Riverpod `Notifier`) owns pending payments. State machine: `awaitingReturn -> verifying -> (confirmed: removed) / unconfirmed`. There is deliberately **no success state**: a payment leaves the set only after the backend says `paid: true` (then the bookings list is refreshed and a "Payment confirmed" snackbar fires) or the reference is invalid (404/403). Verifier runs 5 attempts over 20s (waits 2/4/6/8s). Transient errors (network, 5xx, malformed body) and `paid:false` are retried, never treated as success or terminal. References persist in `shared_preferences` (`pending_payments_v1`, 24h TTL) and are restored + verified when the client shell starts, so a killed app recovers. Observer attached in `MainNavigationPage`; resume triggers `verifyAll()`. Cleared on logout. UI: banner "Confirming payment..." with attempt count, manual "I've paid, check again", and "I didn't pay" to dismiss. | Polling in the page (what existed): lost on kill, tied to one screen. |
| Dead code | Deleted 7 mock/data files, the 3 legacy artisan_home models + `CompletedJobCard`, the "Legacy mock job" branch of `JobDetailPage` (it now takes an `ArtisanBooking`; the route redirects to artisan home if opened without one), hamburger `more_vert` TODO buttons on both booking pages, the share stub on the public artisan profile, and the registration-page Google button (+ its "or" divider). Google sign-in remains on the login page. Support screen untouched (its `mock_support_data.dart` is still used there). | Wiring the registration Google button: it would need a different flow (no password step, role choice), not safe in this PR. |
| Error states | New `core/widgets/common/ErrorState` (friendly text, offline variant, retry) used on bookings, artisan jobs, job history and job detail; `userMessage` replaces `error.toString()` / `e.toString()` in snackbars across ~15 pages. | n/a |
| Crashlytics | Added (`firebase_crashlytics`, Gradle plugin, Dart handlers, off in debug). Needs no certificates. iOS dSYM upload script is not added (see release-prep). | Sentry: second vendor/account. |
| Dojah verification | See [Identity verification](#identity-verification-dojah). | n/a |
| CI | `.github/workflows/ci.yml`: path-filtered (`docs-only` PRs run only the cheap `changes` job), `concurrency` cancel-in-progress, format check on **changed** Dart files only (the legacy code base is not formatted to the current formatter; a repo-wide reformat should be its own PR), `flutter analyze`, `flutter test`, and an Android release-build job that proves R8/Crashlytics config compiles. | Repo-wide `dart format --set-exit-if-changed`: would fail on ~100 untouched files. |

## Identity verification (Dojah hosted widget)
Owner decision: the app does **not** collect the NIN or a selfie itself. It hosts Dojah's Identity widget (`flutter_dojah_kyc`, ported from the owner's Timpbills app) and the backend never sees NIN/selfie. Contract: `fe-integration-guide-verification-admin.md` (backend worktree; captures there are Dojah-stubbed).

Flow (`VerificationFlowController.verify`): camera/mic permissions (so a denial burns no attempt) -> `GET .../verification/config` (`configured:false` => "Not available yet", no start) -> `POST .../verification/start` (one per tap, never auto-retried; each start uses one of 5 attempts/24h) -> launch widget with `reference_id`, `widget_id`, `email` -> `POST .../confirm {reference_id}` -> poll `GET .../status` (5s x 24, only while the screen is open; re-synced on open and on app resume). Any confirm error (502 `provider_error`, 404, timeout, offline) is treated as **pending**, never as a failure. Widget closed/errored => back to idle with "that attempt has been used (N left)".

States on `lib/features/verification/presentation/pages/verify_identity_page.dart`: unverified, pending, verified, failed (backend `failure_reason` verbatim + attempts left + "Try again" = new start), locked (0 attempts, `retry_available_at`, contact support), not-configured, load error/offline with retry. Profile page shows a status tile for artisans. Error codes mapped in `domain/verification_error_messages.dart` (`already_verified`, `attempts_exhausted`, `verification_unavailable`, `unknown_reference`, `provider_error`, 403 artisans-only, network).

All SDK-specific code is isolated in `data/real_dojah_widget_launcher.dart` behind `domain/dojah_widget_launcher.dart` so tests use a fake. The SDK's `open()` never pops its WebView route and force-unwraps all three callbacks, so the launcher passes all three and pops the route itself; the `onSuccess` payload is intentionally ignored (the backend asks Dojah for the authoritative result). **Privacy:** nothing about the widget input is logged or persisted by the app; Dio logging prints no bodies. Native: Android `CAMERA`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`; iOS camera/microphone/location usage strings and `PERMISSION_MICROPHONE=1` in the Podfile. **Not verified:** the real widget on a device, whether `onClose` can fire after `onSuccess`, and the real Dojah round trip.

## What's involved (paths)
- Config: `lib/core/config/api_config.dart`, `lib/core/network/{dio_client,api_exception,dio_error_mapper}.dart`, `README.md`
- Disputes: `lib/features/bookings/domain/dispute_rules.dart`, datasource/repository/provider `disputeCompletion`, `presentation/widgets/{dispute_completion_dialog,completed_booking_card,ongoing_booking_card}.dart`, `presentation/pages/bookings_page.dart`
- Payments: `lib/features/bookings/domain/payment_verification.dart`, `data/pending_payment_store.dart`, `presentation/providers/payment_verification_provider.dart`, `presentation/widgets/pending_payment_banner.dart`, `main_navigation_page.dart` (attach), `core/providers/auth_provider.dart` (clear on logout)
- Verification: `lib/features/verification/**` (+ `flutter_dojah_kyc` in `pubspec.yaml`, `AndroidManifest.xml`, `ios/Runner/Info.plist`), `core/routes/app_router.dart` (`AppRoutes.verifyIdentity`), `features/profile/.../profile_page.dart`
- Release/CI: `android/app/build.gradle.kts`, `android/settings.gradle.kts`, `android/app/proguard-rules.pro`, `android/key.properties.example`, `ios/Podfile`, `pubspec.yaml`, `.gitignore`, `.github/workflows/ci.yml`, `docs/sop/release-prep.md`
- Tests: `test/helpers/`, `test/core/`, `test/features/bookings/`, `test/features/verification/`

## Verification
- `flutter analyze lib test`: no issues.
- Tests run locally (only the touched files): `test/core`, `test/features/bookings` (57 tests: validators, error mapper, booking/wallet/payment datasources against a fake `HttpClientAdapter` incl. 4xx/offline mapping, dispute rules, payment retry/recovery state machine, `PendingPaymentStore`, payment-pending banner widget) and `test/features/verification` (75 tests, fixtures copied from the backend captures). The full suite and the Android release build run in CI only.
- Not verified on a real device: Paystack round trip (external browser + resume), the Dojah widget (camera/liveness), Crashlytics reporting, R8 release build (CI job covers compilation only).
- Dispute and verification have not been exercised against the live backend; payloads were taken from the backend source/contract, not from a live capture.

## UI/UX walkthrough (iOS Simulator, iPhone 17 Pro, no backend reachable)
Built with Flutter 3.38.7 on Xcode 27 using `EXCLUDED_ARCHS[sdk=iphonesimulator*]=x86_64` as a local workaround (Flutter's `debug_unpack_ios` check fails otherwise; not committed) and ad-hoc signing (an unsigned `--no-codesign` simulator build has no keychain entitlement, so secure storage throws -34018 and the splash never navigates). Only the pre-login screens could be walked: no backend was running, so home/search/booking/bookings and the artisan flows (jobs, earnings, profile, verification) were **not** exercised live; they are covered by tests and code review only.

**Found by running the app and fixed:** on iOS the app showed a blank white screen at launch: `FlutterLocalNotificationsPlugin.initialize` threw "iOS settings must be set" because only Android settings were passed, so `main()` died before `runApp`. Fixed (Darwin settings, iOS notification details) and push setup can no longer block start-up. Also replaced a leftover real-looking placeholder email (`jerryhook@woodwork.com`) and phone hint on login, forgot-password and registration.

**Fixed by code review:** raw `DioException` text in snackbars and error panels (~15 pages); error panels without retry (job detail) or offline variant; dead `more_vert` hamburger buttons on both booking pages; invisible share placeholder on the public artisan profile; stub Google button on registration; "Legacy mock job" screen; payment status lost when the app was killed.

**Left (need design/product input):**
- The system notification prompt appears at first launch over a blank screen, before any context; ask after login/onboarding.
- Onboarding uses stock imagery that does not fit: a laptop showing a "Welcome to Pexels" sign-up form on the first slide and a New York (Queens) map on "Find Trusted Artisans Nearby".
- Registration progress shows 4 dots but the flow has 5 steps; the red back arrow does not match the teal headings; registration to login transition cross-fades the two pages together for a moment.
- Booking cards hard-code `isVerified: false` (the bookings API has no artisan verification flag) and say "Completed:"/"Accepted:" next to the job date; the card `more_vert` icon only opens the details sheet.
- Profile "Bank Accounts" entry still disabled and chat hidden (both Phase 2).
- iOS push cannot register until the Push Notifications capability/entitlement is added in Xcode (`aps-environment` missing: FCM logs `no valid aps-environment entitlement`); see `release-prep.md`.

## Operate / roll back
- Run: see README ("Running the app", "Environment defines"). Release builds **must** pass `--dart-define=API_BASE_URL=...`; the default is a non-working placeholder by design.
- Roll back: revert the PR. No migrations. Persisted state added: `pending_payments_v1` in `shared_preferences` (harmless if left behind).

## Follow-ups
- Backend: `GET /payments/verify/{ref}` marks the payment `FAILED` whenever Paystack is not yet `success` (including "pending/abandoned"), so a premature verify poisons the local status until the next successful verify. The app tolerates this (treats `paid:false` as retryable), but the backend should only mark `failed` on a terminal Paystack status.
- Backend: dispute does not appear to hold/notify anything about the artisan beyond the status change; confirm the intended escrow behaviour and push notification to the artisan.
- Decision needed: Sign in with Apple vs. removing Google sign-in on iOS (App Store guideline 4.8), see `release-prep.md`.
- iOS: Flutter 3.38.7 + Xcode 27 needs the x86_64-simulator exclusion shown above to build for the simulator; upgrading Flutter should remove the need.
- Owner assets: app icon source image, upload keystore, APNs key, privacy policy URL.
- Pin third-party GitHub Actions to commit SHAs; add a repo-wide `dart format` PR.
- Add Crashlytics dSYM Run Script on iOS; add `PERMISSION_*` follow-through test on a device.
- Widget/integration tests for the verification page and the bookings page flows (need image_picker/url_launcher fakes).
