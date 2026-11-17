/// Result of `POST .../verification/start`. Each start burns one attempt.
class VerificationStart {
  final String referenceId;
  final String widgetId;
  final String? email;
  final int attemptsRemaining;

  const VerificationStart({
    required this.referenceId,
    required this.widgetId,
    this.email,
    required this.attemptsRemaining,
  });
}
