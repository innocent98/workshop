/// How long and how often the verification screen polls while a verification
/// is `pending`. Polling happens only while the screen is open.
class VerificationPollPolicy {
  VerificationPollPolicy._();

  static const Duration interval = Duration(seconds: 5);

  /// 24 polls x 5 s = 2 minutes, then the screen offers "Check again".
  static const int maxPolls = 24;

  /// Delay before the next poll given how many have already run, or null when
  /// the polling budget is spent.
  static Duration? delayFor(int pollsDone) {
    if (pollsDone < 0) return interval;
    if (pollsDone >= maxPolls) return null;
    return interval;
  }
}
