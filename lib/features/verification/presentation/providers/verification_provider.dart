import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/models/artisan_verification.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/verification_error_messages.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl();
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

class VerificationSubmitState {
  final bool isSubmitting;
  final String? errorMessage;
  final String? errorCode;

  const VerificationSubmitState({
    this.isSubmitting = false,
    this.errorMessage,
    this.errorCode,
  });
}

final verificationSubmitProvider =
    NotifierProvider.autoDispose<
      VerificationSubmitController,
      VerificationSubmitState
    >(VerificationSubmitController.new);

/// Submits the NIN + selfie.
///
/// Privacy: the NIN is only a method argument. It is never stored in [state]
/// (or anywhere else) whether the call succeeds or fails.
class VerificationSubmitController extends Notifier<VerificationSubmitState> {
  @override
  VerificationSubmitState build() => const VerificationSubmitState();

  void clearError() {
    if (state.errorMessage != null) state = const VerificationSubmitState();
  }

  Future<void> submit({required String nin, required File selfie}) async {
    if (state.isSubmitting) return;
    state = const VerificationSubmitState(isSubmitting: true);

    File? compressed;
    try {
      try {
        compressed = await ImageCompressor.compress(selfie);
      } catch (_) {
        throw ApiException(
          verificationErrorMessages['invalid_image']!,
          null,
          'invalid_image',
        );
      }
      if (compressed == null) {
        throw ApiException(
          verificationErrorMessages['invalid_image']!,
          null,
          'invalid_image',
        );
      }

      final result = await ref
          .read(verificationRepositoryProvider)
          .submit(nin: nin, selfie: compressed);

      if (!ref.mounted) return;
      _publish(result);
      state = const VerificationSubmitState();
    } catch (error) {
      if (!ref.mounted) return;
      state = VerificationSubmitState(
        errorMessage: verificationErrorMessage(error),
        errorCode: error is ApiException ? error.code : null,
      );
      if (_shouldResync(error)) await _resyncStatus();
    } finally {
      await _deleteQuietly(compressed);
    }
  }

  void _publish(ArtisanVerification result) {
    if (ref.exists(verificationStatusProvider)) {
      ref.read(verificationStatusProvider.notifier).applyResult(result);
    }
  }

  /// The server may know something we don't: another submit running, an
  /// already-verified account, exhausted attempts, or (after a timeout) a
  /// submit that actually went through.
  bool _shouldResync(Object error) {
    if (error is NetworkException) return true;
    if (error is ApiException) {
      return error.code == 'already_verified' ||
          error.code == 'verification_in_progress' ||
          error.code == 'attempts_exhausted';
    }
    return false;
  }

  Future<void> _resyncStatus() async {
    if (!ref.exists(verificationStatusProvider)) return;
    try {
      await ref.read(verificationStatusProvider.notifier).fetchQuietly();
    } catch (_) {
      // Best effort: the error banner already tells the user what happened.
    }
  }

  Future<void> _deleteQuietly(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Temp file in the cache dir; the OS reclaims it if this fails.
    }
  }
}
