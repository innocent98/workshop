# SOP: Artisan response time + "Report review" (branch `feature/response-time-report-review`)

**What shipped:** the app now shows how fast an artisan usually replies ("Replies in ~12 min") and lets a signed-in user report a review to the moderators. Both consume backend PR #9 (`response_time_avg_minutes`, abusive-review filter, `POST /reviews/{id}/report`). PR: see `gh pr view` for this branch.

Contract source: the backend's `docs/fe-integration-guide-reviews-response-time.md` and its captured responses (`docs/fe-captures/reviews-response-time/`, captures 08 to 11 for response time and 19 to 27 for reporting). Every shape and error string used here is copied from those captures.

## Why
- Customers choose between artisans with only rating and distance. Response time is a strong signal and the backend now computes it (average minutes from request to acceptance over the last 20 accepted bookings; `null` until the first accepted booking, never below 1 once set).
- Reviews were unmoderated from the app's side. The backend added a report queue; the app needed the entry point.

## How (decisions)
| Topic | Decision |
| --- | --- |
| Formatting | `lib/core/utils/response_time_format.dart`: `1-59` -> `~N min`; `60+` -> hours to the nearest half hour (`~1 hr`, `~1.5 hrs`, `~2 hrs`); `24h+` -> days. `null`, `0` and negatives return null, and the `ResponseTimeLabel` widget then renders nothing at all (so no "0", no "N/A", no layout gap). |
| Parsing | `(json['response_time_avg_minutes'] as num?)?.toInt()`: explicit `null` and an absent key (an older backend) both become null. In search results the field sits inside each `results[]` item; on the public profile it is top level (guide, nesting table). |
| Where shown | Artisan public profile (under the rating block), search result card, home carousel card, all-artisans list: every place rating is shown. Not shown on the artisan's own `me/stats` (not asked for). |
| Sorting | The app has no sort control (`SearchArtisansRequest` never sends `sort_by`), so there is nothing to break and nothing added. The backend sorts `null` last in both directions if a sort control is added later. |
| Report UI | A "Report" text button at the bottom right of each review (`ReviewItemWidget`, now a `ConsumerWidget`). It opens `ReportReviewDialog`: pick one of `abusive` / `spam` / `fake` / `other`, then "Report" (disabled until a reason is picked), which doubles as the confirmation. Alternative rejected: a bare yes/no dialog that always sends `other`; the reason helps moderators. |
| Own review | `review.customerId` (new, parsed from `customer_id`) equals the signed-in user id (`currentUserIdProvider`) -> no Report button. If `customer_id` is absent the button shows and the server is the backstop (403 `cannot_report_own_review`). |
| Local state | `reportedReviewIdsProvider` (a `Set<String>` of review ids). On success the button becomes a "Reported" label so it cannot fire twice. The backend has **no field** saying whether the viewer already reported, so a review reported in an earlier session still shows "Report"; the server's 409 then also marks it reported. A per-review in-flight guard blocks double taps. The provider is in `userScopedProviders` so it is cleared on sign-out. |
| Errors | `mapReviewReportError` (`artisan_profile/data/review_report_error.dart`) maps by status and `code` (see table). Raw FastAPI strings are never shown for 422/unknown. |
| Review stays listed | A report never hides a review (guide section 3), so the list is not changed after reporting. |

### Messages (code -> text shown)
| Case (status, code) | Shown | Treated as reported? |
| --- | --- | --- |
| 201 | "Thanks, our team will take a look." | yes |
| 409 `already_reported` | "You've already reported this review." | yes |
| 403 `cannot_report_own_review` | "You can't report your own review." | no |
| 404 `review_not_found` | "This review is no longer available." | no |
| 429 `report_rate_limited` | the backend's message ("You have reported too many reviews recently. Please try again later.") | no |
| 429, other body (per-IP limit) | "You've sent too many reports. Please try again later." | no |
| 403 other | "You need to sign in to report a review." | no |
| 422 / anything else | "Couldn't send your report. Please try again." | no |
| offline | "Network error occurred. Please check your connection." | no |

## What's involved
- New: `lib/core/utils/response_time_format.dart`, `lib/core/widgets/common/response_time_label.dart`, `lib/features/artisan_profile/{data/review_report_error.dart, domain/models/review_report_reason.dart, presentation/providers/report_review_provider.dart, presentation/widgets/report_review_dialog.dart}`.
- Changed: `ArtisanPublicProfile` + response model, `ArtisanSearchModel`, `Artisan` (field carried through `fromSearchModel` and `withPreferredServiceFromQuery`), `Review` + `ReviewResponseModel` (`customerId`), `ArtisanPublicProfileRemoteDataSource` (injectable `Dio`, new `reportReview`), repository interface and impl, `artisan_profile_page.dart`, `artisan_result_card.dart`, `artisan_card.dart`, `all_artisans_page.dart`, `review_item_widget.dart`, `core/providers/session_reset.dart`.
- Tests: `test/core/utils/response_time_format_test.dart`, `test/features/artisan_profile/{response_time_parsing_test.dart, report_review_datasource_test.dart, report_review_flow_test.dart}`.
- No new dependency, no migration, no config. Endpoint: `POST /reviews/{id}/report` body `{"reason": "...", "details": "..."}` (details omitted when blank; the UI does not collect it yet).

## Verification
| Check | Result |
| --- | --- |
| `dart format --set-exit-if-changed` on the changed files, `flutter analyze` | clean locally; CI is the authority |
| Touched tests (formatter, parsing incl. null/absent, datasource body + every captured error shape, widget flow: own review hidden, reason required, success snackbar and "Reported", 409, 429, 404, offline, sign-out scoping) | pass locally (37 tests across the touched files); full suite runs on CI only |
| Request/response shapes | **Taken from the backend's real captures**, replayed here through a fake HTTP adapter. The app itself was **NOT run** against a live backend and not on a simulator or device. |
| Per-IP report limit 429 body | **NOT VERIFIED LIVE** (the guide marks it so); the app shows a generic "slow down" for any 429 that is not `report_rate_limited` |
| `response_time_avg_minutes` on `GET/PUT /profiles/artisans/me` and the availability PATCH | NOT VERIFIED LIVE upstream and not consumed here |
| Layout of the new label on very small screens / large text scale | not checked on a device |

## Operate / roll back
Merge only after backend PR #9 is deployed. Before that the app still works: older backends omit the field (no label) and have no report route (the Report button would answer 404 and show "This review is no longer available."). Revert the PR to remove both features; nothing persists on the device.

## Follow-ups
- Walk both features on a device against a backend with PR #9 (look at the label on narrow cards, the dialog, the snackbar).
- Optional free-text `details` (max 500) in the report dialog, if moderators want it.
- A "you already reported this" flag from the backend would remove the first-tap-then-409 round trip across sessions.
- Review lists elsewhere: today only the artisan profile lists other people's reviews. If an artisan "my reviews" screen is added, it needs the same Report button (the widget already handles it) and a 404 tolerance for hidden reviews (guide section 2).
- Expose `sort_by=response_time` ("Fastest replies") if a sort control is added to search.
