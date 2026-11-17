import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/verification/domain/verification_poll_policy.dart';

void main() {
  test('polls every 5 seconds for about 2 minutes, then stops', () {
    expect(VerificationPollPolicy.delayFor(0), const Duration(seconds: 5));
    expect(VerificationPollPolicy.delayFor(23), const Duration(seconds: 5));
    expect(VerificationPollPolicy.delayFor(24), isNull);
    expect(VerificationPollPolicy.delayFor(100), isNull);
    expect(
      VerificationPollPolicy.interval * VerificationPollPolicy.maxPolls,
      const Duration(minutes: 2),
    );
  });
}
