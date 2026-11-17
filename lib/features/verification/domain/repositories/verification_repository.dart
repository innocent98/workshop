import 'dart:io';

import '../models/artisan_verification.dart';

abstract class VerificationRepository {
  Future<ArtisanVerification> getStatus();

  /// Submits the NIN and selfie. A failed match is a normal outcome (returned
  /// with status `failed`), not an exception.
  Future<ArtisanVerification> submit({
    required String nin,
    required File selfie,
  });
}
