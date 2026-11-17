# SOP: Mobile walkthrough fixes (branch `chore/mobile-walkthrough-fixes`)

**What shipped:** fixes for the defects found when the lead walked the client flow in the iOS simulator against a seeded local backend, plus defects found walking the artisan flow and the Dojah screen. PR: see `gh pr view` for this branch.

## Defects and fixes

| # | Defect | Root cause / fix |
| --- | --- | --- |
| 1 | Logout left the user on the shell with "Failed to load user" + Retry | `PushNotificationService.unregisterCurrentToken()` called `getToken()` outside its try/catch; on iOS it throws (APNs token not set) before the token was deleted. `AuthNotifier.logout()` wrapped it in `AsyncValue.guard`, so auth ended in *error* with token and user still stored; the router redirect bounced `context.go(login)` back to the shell. Now each cleanup step is best-effort and never throws, the token/user are always cleared, auth always ends `data(null)`, `sessionResetProvider` invalidates every account-scoped provider on sign-out (bookings, wallet, profile, notifications, nearby, verification, payment tracking), the 401 path (`endSessionLocally`) uses the same cleanup, and a null user shows a skeleton, never Retry. **Verified in the simulator.** |
| 2 | Stale lists | `ArtisanBookingsNotifier.refreshSilently()` (keeps the visible list, de-duplicates concurrent calls, keeps the old list on failure) is called after a booking is created and whenever the Bookings/Jobs/Home tab is selected. `allArtisansProvider` and `searchArtisansByQueryProvider` are `autoDispose`; the client shell re-invalidates nearby artisans when Home is selected with an empty/errored cache. Not fixed: `servicesProvider` can still cache an error until restart. |
| 3 | Validation errors stayed under valid input | Shared `AppTextField` re-validates on each keystroke while an error is showing (fixes every auth form). |
| 4 | Booking page: odd unchecked checkbox, wrong preselected service, prefilled "optional" budget | New `ServiceCheckbox`; the searched service is carried to the booking page (`Artisan.preferredService`, falls back to the first service when nothing matches). The backend **requires** `budget_min`/`budget_max`, so the instant page keeps a visible default (25,000-35,000) with the helper text "Default range, edit to match your budget" and the "(optional)" label is gone; the schedule page keeps "Ignore Budget" and starts with empty fields. |
| 5 | Pending booking card hid the budget | Shows "Budget: ₦5,000 - ₦8,000". `isVerified` stays false: the bookings API has no artisan verification flag. |
| 6 | Two different support numbers | One source of truth: `lib/core/constants/support_contact.dart` (`SupportContact.phone` = +2347042685209, `phoneDisplay`, `whatsappNumber`). **To change the support number edit only that file.** The home banner now uses the Support page number. |
| 7 | Inconsistent badge colour, un-grouped rates, 0% rating bars, shared stock avatar | One `VerifiedBadge` (green); `formatNaira`/`formatNairaRange` (`lib/core/utils/money_format.dart`) used for every amount (also artisan home/jobs/job detail/history); `RatingDistribution` hidden when all counts are zero; `AvatarPlaceholder`/`ProfileAvatar` (initials) replace the `regular.jpg` fallback. |
| 8 | "Welcome back" twice on login | Subtitle is now "Enter your details to log in". |
| 9 | No account deletion (App Store requirement) | "Delete account" under Logout for both roles, confirmation dialog (type `DELETE`), `AuthRepository.deleteAccount()` -> `DELETE /auth/me`. **The backend endpoint does not exist yet.** Any 2xx is success and runs the full logout cleanup; 404/405/501 show "not available yet, contact support on <SupportContact.phoneDisplay>"; other errors keep the user signed in with a retry. |

## Found while walking the artisan flow (local backend, seeded artisans) and fixed
- Artisan home request card overflowed by 1px (RenderFlex stripes) when the service name wraps to three lines; the list is taller, and the empty "No pending job requests" state is a compact card instead of a 250px grey block.
- Naira amounts without thousand separators everywhere on the artisan side (accept dialog, cards, job detail, history).
- Artisan job cards showed an orange "verified" tick next to the *client* name (clients have no verification) and the name could overflow; removed/made flexible.
- Earnings screen had no title and showed a red "verified" tick next to a payout method that was not set up; title added, tick removed.
- Location gate spun forever when no GPS fix arrived; now times out after 15s into the existing "Unable to get your current location, retry" state.

## Verified live (iOS Simulator, iPhone 17 Pro, backend on :8010)
Login as artisan, artisan home / jobs / earnings / profile, accept a pending request (negotiation dialog -> accepted card "Awaiting payment"), **logout lands on login**, login as an unverified artisan, Identity verification screen -> `config` + `start` calls succeed -> **the real Dojah widget opens inside the app** (permissions prompted correctly after the `PERMISSION_MICROPHONE` macro: microphone then camera) and shows "Invalid Widget ID" because the local backend holds placeholder Dojah credentials -> closing it shows the "attempt has been used" message and then the pending state from `/status`. Not verified: a successful Dojah verification (needs real keys + a camera), delete-account against the real endpoint, the client booking flow after the fixes (covered by the lead's walkthrough + tests).

## Left (product/design input)
- Status call after closing the Dojah widget is slow (the backend re-checks Dojah), so the screen briefly shows the old attempt count before switching to "pending".
- Modal barrier on the verify screen only dims the content area in a screenshot (cosmetic, simulator only?).
- Accept dialog has a large gap between the amount field and the buttons; there is no progress feedback during the ~3s accept call (Accept stays tappable).
- Artisan Jobs tab has no title; job cards on the artisan side do not show the budget range.
- iOS notification prompt appears at first launch before any context; onboarding stock images.

## Verification
`flutter analyze lib test`: no issues. Tests run locally (touched files only): 47 new tests across 10 files (session end/logout regression with a throwing push gateway, delete-account datasource + dialog, silent refresh, app text field re-validation, money format, avatar/badge widgets, rating distribution, request card budget, preferred service). CI runs the full suite.

## Operate / roll back
Revert the PR. No migrations, no new dependencies. `DELETE /auth/me` is called only when the user confirms deletion.
