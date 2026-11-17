import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/real_dojah_widget_launcher.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/dojah_widget_launcher.dart';
import '../../domain/models/artisan_verification.dart';
import '../../domain/models/verification_start.dart';
import '../../domain/models/verification_status.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/verification_error_messages.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl();
});

final dojahWidgetLauncherProvider = Provider<DojahWidgetLauncher>((ref) {
  return RealDojahWidgetLauncher();
});

/// Current verification status. Auto-disposed so nothing lingers (and no
/// polling can continue) once the verify screen is closed.
final verificationStatusProvider =
    AsyncNotifierProvider.autoDispose<
      VerificationStatusController,
      ArtisanVerification
    >(VerificationStatusController.new, retry: (_, _) => null);

class VerificationStatusController extends AsyncNotifier<ArtisanVerification> {
  @override
  Future<ArtisanVerification> build() {
    return ref.read(verificationRepositoryProvider).getStatus();
  }

  /// Re-fetches the status without flipping the UI back to a loading state.
  /// Throws on failure, leaving the previous value in place.
  Future<void> fetchQuietly() async {
    final latest = await ref.read(verificationRepositoryProvider).getStatus();
    if (ref.mounted) state = AsyncData(latest);
  }

  void applyResult(ArtisanVerification result) {
    state = AsyncData(result);
  }
}

enum VerificationFlowPhase {
  idle,
  preparing,
  inWidget,
  confirming,
  notConfigured,
  incomplete,
  error,
}

class VerificationFlowState {
  final VerificationFlowPhase phase;

  /// User-facing error text for `notConfigured`, `incomplete` and `error`.
  final String? message;

  /// Non-error information shown while idle (e.g. the widget was closed).
  final String? notice;

  /// The camera is blocked at OS level, so offer "Open settings".
  final bool needsSettings;

  const VerificationFlowState({
    this.phase = VerificationFlowPhase.idle,
    this.message,
    this.notice,
    this.needsSettings = false,
  });

  bool get isBusy =>
      phase == VerificationFlowPhase.preparing ||
      phase == VerificationFlowPhase.inWidget ||
      phase == VerificationFlowPhase.confirming;
}

final verificationFlowProvider =
    NotifierProvider.autoDispose<
      VerificationFlowController,
      VerificationFlowState
    >(VerificationFlowController.new);

/// Orchestrates: permissions -> config -> start -> Dojah widget -> confirm,
/// then hands over to status polling.
///
/// Rules that matter:
/// * `start` burns an attempt, so it is called at most once per [verify], only
///   after the permission and config checks pass, and never retried here.
/// * A confirm failure of any kind is treated as "still resolving" (pending),
///   never as a failed verification: the backend/webhook finishes the job.
/// * Nothing sensitive is stored in [state] or logged.
class VerificationFlowController extends Notifier<VerificationFlowState> {
  @override
  VerificationFlowState build() => const VerificationFlowState();

  void clearMessages() {
    if (state.message != null || state.notice != null) {
      state = const VerificationFlowState();
    }
  }

  Future<void> verify(BuildContext context) async {
    if (state.isBusy) return;
    state = const VerificationFlowState(phase: VerificationFlowPhase.preparing);

    final repo = ref.read(verificationRepositoryProvider);
    final launcher = ref.read(dojahWidgetLauncherProvider);

    try {
      final permission = await launcher.ensurePermissions();
      if (!ref.mounted) return;
      if (permission != WidgetPermissionResult.granted) {
        final blocked = permission == WidgetPermissionResult.permanentlyDenied;
        state = VerificationFlowState(
          phase: VerificationFlowPhase.error,
          message: blocked
              ? verificationCameraBlockedMessage
              : verificationCameraDeniedMessage,
          needsSettings: blocked,
        );
        return;
      }

      final config = await repo.getConfig();
      if (!ref.mounted) return;
      if (!config.isUsable) {
        // No start call: nothing here may burn an attempt.
        state = const VerificationFlowState(
          phase: VerificationFlowPhase.notConfigured,
          message: verificationNotConfiguredMessage,
        );
        return;
      }

      final started = await repo.start();
      if (!ref.mounted) return;
      if (!context.mounted) {
        // The screen went away after the attempt was spent: let the status
        // provider (and its poller, if reopened) pick it up.
        state = const VerificationFlowState();
        await _resyncStatus();
        return;
      }

      state = const VerificationFlowState(
        phase: VerificationFlowPhase.inWidget,
      );
      final outcome = await launcher.launch(
        context,
        DojahLaunchParams(
          appId: config.appId!,
          publicKey: config.publicKey!,
          widgetId: started.widgetId,
          referenceId: started.referenceId,
          email: started.email,
        ),
      );
      if (!ref.mounted) return;

      switch (outcome) {
        case DojahOutcome.closed:
          state = VerificationFlowState(
            notice: verificationClosedEarlyMessage(started.attemptsRemaining),
          );
          await _resyncStatus();
        case DojahOutcome.error:
          state = VerificationFlowState(
            phase: VerificationFlowPhase.incomplete,
            message: verificationWidgetIncompleteMessage(
              started.attemptsRemaining,
            ),
          );
          await _resyncStatus();
        case DojahOutcome.success:
          state = const VerificationFlowState(
            phase: VerificationFlowPhase.confirming,
          );
          await _confirm(repo, started);
          if (ref.mounted) state = const VerificationFlowState();
      }
    } catch (error) {
      if (!ref.mounted) return;
      state = VerificationFlowState(
        phase: VerificationFlowPhase.error,
        message: verificationErrorMessage(error),
      );
      if (_shouldResync(error)) await _resyncStatus();
    }
  }

  Future<void> _confirm(
    VerificationRepository repo,
    VerificationStart started,
  ) async {
    try {
      final result = await repo.confirm(started.referenceId);
      if (ref.mounted) _publish(result);
    } catch (_) {
      // Any confirm failure (502 provider_error, timeout, offline, odd body)
      // means "still resolving", not "failed": show pending and let the page
      // poll /status.
      if (ref.mounted) _publish(_pendingFor(started));
    }
  }

  ArtisanVerification _pendingFor(VerificationStart started) {
    final previous = ref.exists(verificationStatusProvider)
        ? ref.read(verificationStatusProvider).value
        : null;
    final maxAttempts = previous?.maxAttempts ?? 5;
    return ArtisanVerification(
      status: VerificationStatus.pending,
      referenceId: started.referenceId,
      attemptsUsed: maxAttempts - started.attemptsRemaining,
      attemptsRemaining: started.attemptsRemaining,
      maxAttempts: maxAttempts,
      windowHours: previous?.windowHours ?? 24,
    );
  }

  void _publish(ArtisanVerification result) {
    if (ref.exists(verificationStatusProvider)) {
      ref.read(verificationStatusProvider.notifier).applyResult(result);
    }
  }

  /// The server may know something we don't: an already-verified account,
  /// exhausted attempts, or (after a timeout) a start that went through.
  bool _shouldResync(Object error) {
    if (error is NetworkException) return true;
    if (error is ApiException) {
      return error.code == 'already_verified' ||
          error.code == 'attempts_exhausted';
    }
    return false;
  }

  Future<void> _resyncStatus() async {
    if (!ref.exists(verificationStatusProvider)) return;
    try {
      await ref.read(verificationStatusProvider.notifier).fetchQuietly();
    } catch (_) {
      // Best effort: the screen already tells the user what happened.
    }
  }
}
