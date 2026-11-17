import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/bookings/data/models/artisan_booking_response_model.dart';
import 'package:workchop/features/bookings/domain/dispute_rules.dart';
import 'package:workchop/features/bookings/domain/models/artisan_booking.dart';

import '../../helpers/booking_fixtures.dart';

ArtisanBooking _booking(Map<String, dynamic> json) =>
    ArtisanBookingResponseModel.fromJson(json).toDomain();

void main() {
  group('validateDisputeReason (backend: 10..500 chars)', () {
    test('rejects empty and whitespace-only', () {
      expect(validateDisputeReason(null), isNotNull);
      expect(validateDisputeReason('   '), isNotNull);
    });

    test('counts the trimmed text', () {
      expect(validateDisputeReason('  short   '), isNotNull);
      expect(validateDisputeReason('${' ' * 5}123456789${' ' * 5}'), isNotNull);
      expect(validateDisputeReason('1234567890'), isNull);
    });

    test('rejects more than 500 characters', () {
      expect(validateDisputeReason('a' * 500), isNull);
      expect(validateDisputeReason('a' * 501), isNotNull);
    });
  });

  group('canDisputeCompletion', () {
    final now = DateTime.utc(2030, 6, 1);

    test('open completed job inside the window can be disputed', () {
      final b = _booking(bookingJson(deadlineAt: '2030-06-02T00:00:00Z'));
      expect(canDisputeCompletion(b, now: now), isTrue);
    });

    test('no deadline from the server still allows dispute', () {
      final b = _booking(bookingJson(deadlineAt: null));
      expect(canDisputeCompletion(b, now: now), isTrue);
    });

    test('past the deadline cannot be disputed', () {
      final b = _booking(bookingJson(deadlineAt: '2030-05-30T00:00:00Z'));
      expect(canDisputeCompletion(b, now: now), isFalse);
    });

    test('already confirmed or disputed cannot be disputed', () {
      final confirmed = _booking(
        bookingJson(confirmedAt: '2030-05-31T00:00:00Z'),
      );
      final disputed = _booking(
        bookingJson(
          status: 'disputed',
          disputedAt: '2030-05-31T00:00:00Z',
          disputeReason: 'Not fixed at all',
        ),
      );
      expect(canDisputeCompletion(confirmed, now: now), isFalse);
      expect(canDisputeCompletion(disputed, now: now), isFalse);
    });

    test('only completed jobs can be disputed', () {
      for (final status in ['pending', 'accepted', 'paid', 'in_progress']) {
        final b = _booking(bookingJson(status: status));
        expect(canDisputeCompletion(b, now: now), isFalse, reason: status);
      }
    });
  });
}
