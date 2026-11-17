# SOP: Delete account, end to end (branch `fix/delete-account-e2e`)

**What shipped:** the in-app "Delete account" flow now actually works against the real backend (`DELETE /auth/me`, backend PR #5). Before this branch it could never succeed for a password account. PR: see `gh pr view` for this branch.

## Why
The delete-account UI (mobile PR #2) was written before the backend endpoint existed. The endpoint that later shipped requires re-authentication in the request body; the app sent `DELETE /auth/me` with no body. Walking the flow in the iOS simulator against a local backend built from backend `main` (0f815c9) found three defects:

| # | Defect | Root cause | Fix |
| --- | --- | --- | --- |
| 1 | Deleting always failed | App sent no body; backend answers `400 password_required` (password accounts) or `400 reauth_required` (Google-only). Captured: `api-01-app-style-delete-no-body.txt`. | `deleteAccount({password, googleToken})` threads through provider, repository and datasource and sends `{"password": ...}` or `{"google_token": ...}`. The dialog has a password field; a blank password on a Google-only account makes the backend answer `reauth_required`, the dialog then switches to "Confirm with Google" and retries with a fresh Firebase ID token (`lib/features/auth/data/google_reauth.dart`). |
| 2 | Wrong-password / blocked / too-many-attempts reasons were lost | `AuthInterceptor.onError` did `data['detail'] as String?`. The deletion errors use `detail = {code, message, ...}` so the cast threw, hiding the real message behind a generic one. | Use `parseErrorBody` (already understands string, object and list `detail`). |
| 3 | A failed login showed (almost) no message | A 401 from `/auth/login` was treated as a forced logout: it rebuilt the login route and removed the error snackbar a few frames after it appeared. This hid "Invalid email or password", which is also what a deleted account gets. | `/auth/login` and `/auth/google` added to the interceptor's non-critical 401 paths (no session exists to kill). |

Also: the helper text under the password field was truncated, shortened to "Google account? Leave blank."

## How (decisions)
- Password is **always asked** (no signal in the login payload about whether the account has one). A Google-only user leaves it blank; the backend's `reauth_required` is the signal. Alternative rejected: an `has_password` flag, needs a backend change.
- Blocker texts are **not mapped by code in the app**. The backend returns a readable `message` for every blocker (`active_bookings`, `unfinished_withdrawal`, `refund_pending`, `wallet_balance`, joined in one sentence when several apply); the app shows it verbatim.

## What's involved
`lib/core/network/auth_interceptor.dart`, `lib/core/providers/auth_provider.dart`, `lib/features/auth/{data/datasources/auth_remote_datasource.dart, data/repositories/auth_repository_impl.dart, domain/repositories/auth_repository.dart, data/google_reauth.dart}`, `lib/features/profile/presentation/{widgets/delete_account_dialog.dart, pages/profile_page.dart}`. Tests: `test/core/network/auth_interceptor_test.dart` (new), `test/features/auth/delete_account_datasource_test.dart`, `test/features/profile/delete_account_dialog_test.dart`. No backend change, no migration, no new dependency.

## Verification
Local backend from `docker compose` (db, redis, api; migrations at head `d3f5a7c9e1b2`), app built with `API_BASE_URL=http://localhost:8010/api/v1` on iPhone 17 Pro. Evidence (screenshots + captured API bodies) is kept with the session notes (`e2e-delete/`), not committed.

| Case | Result |
| --- | --- |
| Wrong password (client) | **Verified live in the app**: "The password is incorrect." + "not deleted, still signed in" (403 `invalid_password`) |
| Correct password, no bookings (client) | **Verified live in the app**: account deleted (row anonymised, `deleted_at` set, inactive), app returns to the login screen |
| Same flow, artisan | Verified live **via API only** (403, then 200, old token then 401 "Token has been revoked", login then 401) |
| Log in again as the deleted account | **Verified live in the app** after fix 3: "Invalid email or password" (the backend deliberately does not say "deleted") |
| Active booking blocks deletion (client) | **Verified live in the app**: "Your account cannot be deleted yet: Finish or cancel your accepted, paid, in-progress and disputed bookings." Artisan side verified via API (409). |
| Too many attempts | **Verified live in the app** (5 wrong attempts via API, then the app): "Too many incorrect attempts. Please try again in a few minutes." (429) |
| Blockers `unfinished_withdrawal`, `refund_pending`, `wallet_balance` | **NOT triggered live.** Texts come from the backend's `BLOCKER_MESSAGES`; the app path is the same as `active_bookings` and is covered by the datasource test. |
| Google-only re-auth (`reauth_required` then Google token) | **NOT VERIFIED**: no Google/Firebase account in the local setup. Covered by widget tests with a fake token provider and by the datasource body test only. |
| App behaviour on `main` before the fix | Not captured in the simulator (the simulator build of `main` kept stalling on a memory-starved machine). The request the old app sent was captured at API level (`api-01`); the login snackbar defect (fix 3) was seen live before and after the fix; fix 2 was only seen working after the fix (and is pinned by a unit test). |

Local checks: `flutter analyze` on touched dirs, `dart format --set-exit-if-changed` on touched files, 47 touched tests (network, datasource, dialog, session end). CI runs the full suite.

## Operate / roll back
Revert the PR; the old UI would again fail against the backend. The login 401 change affects only `/auth/login` and `/auth/google`.

## Follow-ups
- Real Google re-auth round trip on a device with a Google-only account.
- Trigger the other three blocker codes live once test data for withdrawals/refunds exists.
- The delete dialog on a small screen with the keyboard open was not checked.
- Local-run notes: Flutter 3.38.7 on Xcode 27 needs `EXCLUDED_ARCHS[sdk=iphonesimulator*]=x86_64` appended to `ios/Flutter/Debug.xcconfig` (never commit it) and `codesign --force --sign -` on the built `Runner.app`.
