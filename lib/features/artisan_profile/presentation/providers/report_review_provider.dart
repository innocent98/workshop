import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/review_report_error.dart';
import '../../domain/models/review_report_reason.dart';
import 'artisan_public_profile_providers.dart';

/// Id of the signed-in user (null when signed out). A tiny seam so widgets can
/// ask "is this my review?" without depending on the whole auth notifier.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authProvider.select((auth) => auth.value?.id)),
);

/// What happened when the user tried to report a review.
class ReportReviewResult {
  final bool success;
  final String message;

  const ReportReviewResult.success(this.message) : success = true;
  const ReportReviewResult.failure(this.message) : success = false;
}

/// Ids of the reviews this user has reported in the current session, so the
/// "Report" action can be replaced by "Reported" and cannot fire twice.
///
/// The backend has no field saying whether the viewer already reported a
/// review, so a review reported in an earlier session still shows "Report";
/// the server then answers 409 `already_reported` and we mark it here too.
class ReportedReviewsNotifier extends Notifier<Set<String>> {
  final Set<String> _inFlight = <String>{};

  @override
  Set<String> build() => const <String>{};

  Future<ReportReviewResult> report(
    String reviewId,
    ReviewReportReason reason,
  ) async {
    if (state.contains(reviewId)) {
      return const ReportReviewResult.success(
        "You've already reported this review.",
      );
    }
    if (!_inFlight.add(reviewId)) {
      return const ReportReviewResult.failure(
        'Your report is already being sent.',
      );
    }
    try {
      await ref
          .read(artisanPublicProfileRepositoryProvider)
          .reportReview(reviewId, reason);
      _markReported(reviewId);
      return const ReportReviewResult.success(
        'Thanks, our team will take a look.',
      );
    } on ApiException catch (e) {
      // 409: the user did report it before (earlier session); treat as done.
      if (e.code == ReviewReportCodes.alreadyReported) {
        _markReported(reviewId);
        return ReportReviewResult.success(e.message);
      }
      return ReportReviewResult.failure(e.message);
    } catch (e) {
      return ReportReviewResult.failure(
        userMessage(
          e,
          fallback: "Couldn't send your report. Please try again.",
        ),
      );
    } finally {
      _inFlight.remove(reviewId);
    }
  }

  void _markReported(String reviewId) {
    if (ref.mounted) state = {...state, reviewId};
  }
}

final reportedReviewIdsProvider =
    NotifierProvider<ReportedReviewsNotifier, Set<String>>(
      ReportedReviewsNotifier.new,
    );
