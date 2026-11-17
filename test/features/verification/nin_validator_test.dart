import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/verification/domain/nin_validator.dart';

void main() {
  group('NinValidator.validate', () {
    test('accepts exactly 11 digits', () {
      expect(NinValidator.validate('00000000000'), isNull);
      expect(NinValidator.validate('12345678901'), isNull);
      expect(NinValidator.isValid('12345678901'), isTrue);
    });

    test('trims surrounding whitespace', () {
      expect(NinValidator.validate('  12345678901 '), isNull);
    });

    test('rejects null and empty', () {
      expect(NinValidator.validate(null), 'Enter your 11-digit NIN');
      expect(NinValidator.validate(''), 'Enter your 11-digit NIN');
      expect(NinValidator.validate('   '), 'Enter your 11-digit NIN');
    });

    test('rejects too short and too long', () {
      expect(
        NinValidator.validate('1234567890'),
        'Your NIN must be exactly 11 digits',
      );
      expect(
        NinValidator.validate('123456789012'),
        'Your NIN must be exactly 11 digits',
      );
    });

    test('rejects non-digit characters', () {
      const message = 'Your NIN can only contain digits';
      expect(NinValidator.validate('1234567890a'), message);
      expect(NinValidator.validate('1234 567 8901'), message);
      expect(NinValidator.validate('12345-67890'), message);
      expect(NinValidator.validate('١٢٣٤٥٦٧٨٩٠١'), message);
      expect(NinValidator.isValid('abc'), isFalse);
    });
  });
}
