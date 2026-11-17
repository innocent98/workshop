import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('rejects null, empty and whitespace', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('   '), 'This field is required');
    });

    test('uses the field name in the message', () {
      expect(Validators.required('', 'Name'), 'Name is required');
    });

    test('accepts a value', () {
      expect(Validators.required('Ada'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects empty and malformed addresses', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      for (final bad in ['plain', 'a@b', '@x.com', 'a b@x.com', 'a@x.c']) {
        expect(
          Validators.email(bad),
          'Please enter a valid email',
          reason: bad,
        );
      }
    });

    test('accepts valid addresses', () {
      for (final ok in ['a@x.com', 'first.last+tag@sub.example.ng']) {
        expect(Validators.email(ok), isNull, reason: ok);
      }
    });
  });

  group('Validators.password', () {
    test('requires 8+ characters', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
      expect(
        Validators.password('1234567'),
        'Password must be at least 8 characters',
      );
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.phone', () {
    test('accepts local and international formats', () {
      for (final ok in ['08012345678', '+2348012345678', '0801 234 5678']) {
        expect(Validators.phone(ok), isNull, reason: ok);
      }
    });

    test('rejects empty, short and lettered numbers', () {
      expect(Validators.phone(''), 'Phone number is required');
      expect(Validators.phone('12345'), 'Please enter a valid phone number');
      expect(
        Validators.phone('0801abc5678'),
        'Please enter a valid phone number',
      );
    });
  });
}
