import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A payment the user started but we have not yet confirmed.
class StoredPendingPayment {
  final int bookingId;
  final String reference;
  final DateTime startedAt;

  const StoredPendingPayment({
    required this.bookingId,
    required this.reference,
    required this.startedAt,
  });

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'reference': reference,
    'started_at': startedAt.toUtc().toIso8601String(),
  };

  static StoredPendingPayment? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = json['booking_id'];
    final ref = json['reference'];
    final started = DateTime.tryParse('${json['started_at']}');
    if (id is! int || ref is! String || ref.isEmpty || started == null) {
      return null;
    }
    return StoredPendingPayment(
      bookingId: id,
      reference: ref,
      startedAt: started,
    );
  }
}

/// Persists pending Paystack references (not secrets: they are opaque ids the
/// authenticated user already holds) so a killed app can still verify them on
/// the next launch. Entries older than [maxAge] are discarded.
class PendingPaymentStore {
  PendingPaymentStore({
    this.maxAge = const Duration(hours: 24),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const String _key = 'pending_payments_v1';

  final Duration maxAge;
  final DateTime Function() _now;

  Future<List<StoredPendingPayment>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final cutoff = _now().subtract(maxAge);
      return [
        for (final item in decoded)
          if (StoredPendingPayment.tryParse(item) case final p?)
            if (p.startedAt.isAfter(cutoff)) p,
      ];
    } on FormatException {
      return const [];
    }
  }

  Future<void> put(StoredPendingPayment payment) async {
    final current = await load();
    final next = [
      for (final p in current)
        if (p.bookingId != payment.bookingId) p,
      payment,
    ];
    await _save(next);
  }

  Future<void> remove(int bookingId) async {
    final current = await load();
    await _save([
      for (final p in current)
        if (p.bookingId != bookingId) p,
    ]);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<StoredPendingPayment> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final p in items) p.toJson()]),
    );
  }
}
