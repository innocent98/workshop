import '../../../../core/network/api_exception.dart';
import '../../domain/models/verification_start.dart';

/// Wire model for `POST .../verification/start`.
class StartVerificationResponse {
  final String referenceId;
  final String widgetId;
  final String? email;
  final int attemptsRemaining;

  const StartVerificationResponse({
    required this.referenceId,
    required this.widgetId,
    this.email,
    required this.attemptsRemaining,
  });

  /// A start response without a reference or widget id is unusable, so that
  /// (and only that) is an error.
  factory StartVerificationResponse.fromJson(Map<String, dynamic> json) {
    final reference = json['reference_id'];
    final widget = json['widget_id'];
    if (reference is! String ||
        reference.isEmpty ||
        widget is! String ||
        widget.isEmpty) {
      throw ApiException('Unexpected response from the server');
    }
    final email = json['email'];
    final remaining = json['attempts_remaining'];
    return StartVerificationResponse(
      referenceId: reference,
      widgetId: widget,
      email: email is String && email.isNotEmpty ? email : null,
      attemptsRemaining: remaining is num ? remaining.toInt() : 0,
    );
  }

  VerificationStart toDomain() => VerificationStart(
    referenceId: referenceId,
    widgetId: widgetId,
    email: email,
    attemptsRemaining: attemptsRemaining,
  );
}
