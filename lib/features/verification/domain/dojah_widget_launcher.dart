import 'package:flutter/widgets.dart';

/// How the Dojah widget session ended. Which callback fired is the only
/// signal used: the payload is opaque and the backend gets the authoritative
/// result from Dojah itself.
enum DojahOutcome { success, closed, error }

enum WidgetPermissionResult { granted, denied, permanentlyDenied }

/// Everything the widget needs. Credentials: never log or persist.
class DojahLaunchParams {
  final String appId;
  final String publicKey;
  final String widgetId;
  final String referenceId;
  final String? email;

  const DojahLaunchParams({
    required this.appId,
    required this.publicKey,
    required this.widgetId,
    required this.referenceId,
    this.email,
  });
}

/// The only seam to the Dojah SDK. The real implementation lives in
/// `data/real_dojah_widget_launcher.dart`; tests inject a fake.
abstract class DojahWidgetLauncher {
  /// Asks for the permissions the widget needs. Called before `start` so a
  /// denied camera never burns an attempt.
  Future<WidgetPermissionResult> ensurePermissions();

  /// Opens the widget on [context]'s navigator and completes once it has been
  /// dismissed. Completes exactly once, and always leaves the navigator as it
  /// found it.
  Future<DojahOutcome> launch(BuildContext context, DojahLaunchParams params);
}
