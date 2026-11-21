import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/utils/response_time_format.dart';

void main() {
  group('formatResponseTime', () {
    test('null means no data: nothing to show', () {
      expect(formatResponseTime(null), isNull);
      expect(responseTimeLabel(null), isNull);
    });

    test('never renders zero or negative values', () {
      expect(formatResponseTime(0), isNull);
      expect(formatResponseTime(-5), isNull);
      expect(responseTimeLabel(0), isNull);
    });

    test('minutes below an hour', () {
      expect(formatResponseTime(1), '~1 min');
      expect(formatResponseTime(12), '~12 min');
      expect(formatResponseTime(33), '~33 min');
      expect(formatResponseTime(59), '~59 min');
    });

    test('hours round to the nearest half hour', () {
      expect(formatResponseTime(60), '~1 hr');
      expect(formatResponseTime(70), '~1 hr');
      expect(formatResponseTime(90), '~1.5 hrs');
      expect(formatResponseTime(120), '~2 hrs');
      expect(formatResponseTime(125), '~2 hrs');
      expect(formatResponseTime(150), '~2.5 hrs');
      expect(formatResponseTime(23 * 60), '~23 hrs');
    });

    test('a day or more', () {
      expect(formatResponseTime(24 * 60), '~1 day');
      expect(formatResponseTime(48 * 60), '~2 days');
    });

    test('label wording', () {
      expect(responseTimeLabel(12), 'Replies in ~12 min');
      expect(responseTimeLabel(120), 'Replies in ~2 hrs');
    });

    test('output never contains a bare "0" label or N/A', () {
      for (final m in [null, 0, 1, 5, 59, 60, 61, 600, 1440]) {
        final text = formatResponseTime(m) ?? '';
        expect(text.contains('N/A'), isFalse);
        expect(text == '~0 min', isFalse);
      }
    });
  });
}
