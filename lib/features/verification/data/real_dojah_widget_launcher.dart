import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_dojah_kyc/flutter_dojah_kyc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/dojah_widget_launcher.dart';

/// Wraps `flutter_dojah_kyc` (^0.6.8, resolved 0.6.11). All SDK-specific code
/// lives in this file.
///
/// Facts confirmed against the package source:
/// * `DojahKYC.open` pushes a `MaterialPageRoute` with its WebView and never
///   pops it: it only fires a callback. So this wrapper pops the route itself
///   on the first callback.
/// * `open` force-unwraps `onSuccess`, `onClose` and `onError`, so all three
///   must be supplied.
/// * The returned future completes when the route is popped, so a system back
///   gesture (no callback) is detected and reported as [DojahOutcome.closed].
/// * The WebView screen shows a spinner forever if the camera is denied, which
///   is why permissions are requested up front in [ensurePermissions].
class RealDojahWidgetLauncher implements DojahWidgetLauncher {
  @override
  Future<WidgetPermissionResult> ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    final camera = statuses[Permission.camera];
    if (camera != null && camera.isGranted) {
      return WidgetPermissionResult.granted;
    }
    if (camera != null && (camera.isPermanentlyDenied || camera.isRestricted)) {
      return WidgetPermissionResult.permanentlyDenied;
    }
    return WidgetPermissionResult.denied;
  }

  @override
  Future<DojahOutcome> launch(BuildContext context, DojahLaunchParams params) {
    final completer = Completer<DojahOutcome>();
    final navigator = Navigator.of(context);

    void finish(DojahOutcome outcome) {
      if (completer.isCompleted) return;
      completer.complete(outcome);
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    }

    final email = params.email;
    final dojah = DojahKYC(
      appId: params.appId,
      publicKey: params.publicKey,
      type: 'custom',
      referenceId: params.referenceId,
      config: {'widget_id': params.widgetId},
      userData: {if (email != null && email.isNotEmpty) 'email': email},
    );

    dojah
        .open(
          context,
          onSuccess: (_) => finish(DojahOutcome.success),
          onClose: (_) => finish(DojahOutcome.closed),
          onError: (_) => finish(DojahOutcome.error),
        )
        .then((_) {
          // Route popped without a callback (system back): treat as closed.
          if (!completer.isCompleted) completer.complete(DojahOutcome.closed);
        })
        .catchError((Object _) {
          if (!completer.isCompleted) completer.complete(DojahOutcome.error);
        });

    return completer.future;
  }
}
