import '../models/artisan_verification.dart';
import '../models/dojah_widget_config.dart';
import '../models/verification_start.dart';

abstract class VerificationRepository {
  Future<DojahWidgetConfig> getConfig();

  /// Mints a reference and records a pending verification. Counts as one
  /// attempt, so callers must never call it automatically or in a retry loop.
  Future<VerificationStart> start();

  /// Tells the backend the widget finished. May return `pending`.
  Future<ArtisanVerification> confirm(String referenceId);

  Future<ArtisanVerification> getStatus();
}
