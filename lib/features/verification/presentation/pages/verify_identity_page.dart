import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../domain/models/artisan_verification.dart';
import '../../domain/models/verification_status.dart';
import '../../domain/nin_validator.dart';
import '../../domain/verification_error_messages.dart';
import '../../domain/verification_poll_policy.dart';
import '../providers/verification_provider.dart';
import '../widgets/selfie_capture_card.dart';
import '../widgets/verification_state_views.dart';

/// "Verify your identity": NIN + live selfie, submitted as one multipart
/// request. Reflects unverified / pending / verified / failed.
///
/// Privacy: the NIN lives only in [_ninController] and is cleared as soon as a
/// submit finishes (success or failure). The selfie file is held only until
/// the upload completes and is then deleted. Neither is logged, persisted or
/// put in a route.
class VerifyIdentityPage extends ConsumerStatefulWidget {
  const VerifyIdentityPage({super.key});

  @override
  ConsumerState<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends ConsumerState<VerifyIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _ninController = TextEditingController();
  final _picker = ImagePicker();

  File? _selfie;

  ProviderSubscription<AsyncValue<ArtisanVerification>>? _statusSub;
  Timer? _pollTimer;
  int _pollCount = 0;
  bool _pollingStopped = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _statusSub = ref.listenManual(
      verificationStatusProvider,
      _onStatusChanged,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _statusSub?.close();
    _ninController.dispose();
    _deleteFile(_selfie);
    super.dispose();
  }

  // ---- polling (only while this screen is open and status is pending) ----

  void _onStatusChanged(
    AsyncValue<ArtisanVerification>? previous,
    AsyncValue<ArtisanVerification> next,
  ) {
    if (!next.hasValue) return;
    final status = next.value!.status;
    final previousStatus = previous?.value?.status;

    if (status == VerificationStatus.pending) {
      if (previousStatus != VerificationStatus.pending) _startPolling();
      return;
    }
    _stopPolling();
    if (status == VerificationStatus.verified &&
        previousStatus != VerificationStatus.verified) {
      ref.invalidate(artisanProfileProvider);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollCount = 0;
    _setPollingStopped(false);
    _schedulePoll();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollCount = 0;
    _setPollingStopped(false);
  }

  void _schedulePoll() {
    final delay = VerificationPollPolicy.delayFor(_pollCount);
    if (delay == null) {
      _setPollingStopped(true);
      return;
    }
    _pollTimer = Timer(delay, () async {
      _pollCount++;
      try {
        await ref.read(verificationStatusProvider.notifier).fetchQuietly();
      } catch (_) {
        // Transient: try again on the next tick until the budget is spent.
      }
      if (!mounted) return;
      final status = ref.read(verificationStatusProvider).value?.status;
      if (status == VerificationStatus.pending) _schedulePoll();
    });
  }

  void _setPollingStopped(bool value) {
    if (!mounted || _pollingStopped == value) return;
    setState(() => _pollingStopped = value);
  }

  Future<void> _checkAgain() async {
    setState(() => _isChecking = true);
    try {
      await ref.read(verificationStatusProvider.notifier).fetchQuietly();
      final status = ref.read(verificationStatusProvider).value?.status;
      if (mounted && status == VerificationStatus.pending) _startPolling();
    } catch (e) {
      _showSnack(verificationErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _refresh() async {
    try {
      await ref.read(verificationStatusProvider.notifier).fetchQuietly();
    } catch (e) {
      _showSnack(verificationErrorMessage(e));
    }
  }

  // ---- selfie ----

  Future<void> _captureSelfie() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1600,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (picked == null || !mounted) return;
      final previous = _selfie;
      setState(() => _selfie = File(picked.path));
      ref.read(verificationSubmitProvider.notifier).clearError();
      await _deleteFile(previous);
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied' ||
          e.code == 'camera_access_restricted') {
        await _showCameraDeniedDialog();
      } else {
        _showSnack("We couldn't open the camera. Please try again.");
      }
    }
  }

  Future<void> _showCameraDeniedDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Camera access needed'),
        content: const Text(
          'We need your camera to take a live selfie. Nothing is saved to '
          'your photo library. Turn on camera access in Settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Camera temp file in the cache dir; the OS reclaims it if this fails.
    }
  }

  // ---- submit ----

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final selfie = _selfie;
    if (selfie == null) {
      _showSnack('Take a selfie to continue.');
      return;
    }

    try {
      await ref
          .read(verificationSubmitProvider.notifier)
          .submit(nin: _ninController.text.trim(), selfie: selfie);
    } finally {
      // Whatever the outcome, neither the NIN nor the selfie is kept.
      _ninController.clear();
      final used = _selfie;
      if (mounted) setState(() => _selfie = null);
      await _deleteFile(used);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(verificationStatusProvider);
    final submit = ref.watch(verificationSubmitProvider);

    return PopScope(
      canPop: !submit.isSubmitting,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: BodyText(
            'Verify your identity',
            size: BodySize.large,
            fontWeight: FontWeight.w500,
          ),
        ),
        body: Stack(
          children: [
            statusAsync.when(
              loading: () => const VerificationSkeleton(),
              error: (error, _) => VerificationMessageView(
                offline: error is NetworkException,
                message: verificationErrorMessage(error),
                onRetry: () => ref.invalidate(verificationStatusProvider),
              ),
              data: (verification) => _buildContent(verification, submit),
            ),
            if (submit.isSubmitting) const _SubmittingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ArtisanVerification verification,
    VerificationSubmitState submit,
  ) {
    final Widget body;
    if (verification.status == VerificationStatus.verified) {
      body = VerificationVerifiedView(
        verification: verification,
        onDone: () => context.pop(),
      );
    } else if (verification.status == VerificationStatus.pending) {
      body = VerificationPendingView(
        pollingStopped: _pollingStopped,
        isChecking: _isChecking,
        onCheckAgain: _checkAgain,
      );
    } else if (verification.isLockedOut) {
      body = VerificationLockedOutView(verification: verification);
    } else {
      body = _buildForm(verification, submit);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.all(16.r),
        child: body,
      ),
    );
  }

  Widget _buildForm(
    ArtisanVerification verification,
    VerificationSubmitState submit,
  ) {
    final isRetry = verification.status == VerificationStatus.failed;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRetry) ...[
            VerificationFailureBanner(verification: verification),
            SizedBox(height: 20.h),
          ] else ...[
            BodyText(
              'Get your verified badge',
              size: BodySize.large,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 4.h),
            BodyText(
              'Enter your NIN and take a quick selfie so we can confirm it is '
              'really you. You can keep taking jobs while we check.',
              size: BodySize.medium,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 20.h),
          ],
          BodyText(
            'National Identification Number (NIN)',
            size: BodySize.medium,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _ninController,
            enabled: !submit.isSubmitting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            maxLength: NinValidator.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: NinValidator.validate,
            onChanged: (_) =>
                ref.read(verificationSubmitProvider.notifier).clearError(),
            decoration: InputDecoration(
              hintText: '11 digits',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          BodyText(
            'Live selfie',
            size: BodySize.medium,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8.h),
          SelfieCaptureCard(
            selfie: _selfie,
            enabled: !submit.isSubmitting,
            onCapture: _captureSelfie,
          ),
          SizedBox(height: 16.h),
          _TrustNote(
            maxAttempts: verification.maxAttempts,
            windowHours: verification.windowHours,
          ),
          if (submit.errorMessage != null) ...[
            SizedBox(height: 16.h),
            _SubmitError(message: submit.errorMessage!),
          ],
          SizedBox(height: 24.h),
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: submit.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: BodyText(
                isRetry ? 'Try again' : 'Verify my identity',
                size: BodySize.medium,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: BodyText(
              verification.attemptsRemaining == 1
                  ? '1 attempt left'
                  : '${verification.attemptsRemaining} attempts left',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _TrustNote extends StatelessWidget {
  final int maxAttempts;
  final int windowHours;

  const _TrustNote({required this.maxAttempts, required this.windowHours});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 16.r, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: BodyText(
            'Your NIN and selfie are used only to check your identity and '
            'are never stored. We keep just the last 4 digits of your NIN. '
            'You get $maxAttempts attempts every $windowHours hours.',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SubmitError extends StatelessWidget {
  final String message;

  const _SubmitError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 18.r, color: AppColors.error),
            SizedBox(width: 8.w),
            Expanded(
              child: BodyText(
                message,
                size: BodySize.medium,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmittingOverlay extends StatelessWidget {
  const _SubmittingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.45),
            dismissible: false,
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  BodyText(
                    'Verifying your identity',
                    size: BodySize.large,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  BodyText(
                    'This can take up to a minute. Please keep the app open.',
                    size: BodySize.small,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
