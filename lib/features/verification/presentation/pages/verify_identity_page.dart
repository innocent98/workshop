import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../domain/models/artisan_verification.dart';
import '../../domain/models/verification_status.dart';
import '../../domain/verification_error_messages.dart';
import '../../domain/verification_poll_policy.dart';
import '../providers/verification_provider.dart';
import '../widgets/verification_state_views.dart';

/// "Verify your identity": launches Dojah's hosted Identity widget, which
/// collects the NIN and selfie itself. Reflects unverified / pending /
/// verified / failed.
///
/// Privacy: this app never sees the NIN or the selfie, so there is nothing of
/// either to log, store or clear. The Dojah credentials and the reference id
/// are never logged or persisted.
class VerifyIdentityPage extends ConsumerStatefulWidget {
  const VerifyIdentityPage({super.key});

  @override
  ConsumerState<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends ConsumerState<VerifyIdentityPage>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<ArtisanVerification>>? _statusSub;
  Timer? _pollTimer;
  int _pollCount = 0;
  bool _pollingStopped = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statusSub = ref.listenManual(
      verificationStatusProvider,
      _onStatusChanged,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _statusSub?.close();
    super.dispose();
  }

  /// A result can arrive while the app is in the background (webhook), so
  /// re-check on resume, unless a verification is mid-flight.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (ref.read(verificationFlowProvider).isBusy) return;
    _refresh(showErrors: false);
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

  Future<void> _refresh({bool showErrors = true}) async {
    try {
      await ref.read(verificationStatusProvider.notifier).fetchQuietly();
    } catch (e) {
      if (showErrors) _showSnack(verificationErrorMessage(e));
    }
  }

  // ---- start ----

  Future<void> _startVerification() async {
    await ref.read(verificationFlowProvider.notifier).verify(context);
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
    final flow = ref.watch(verificationFlowProvider);

    return PopScope(
      canPop: !flow.isBusy,
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
              data: (verification) => _buildContent(verification, flow),
            ),
            if (flow.isBusy) _BusyOverlay(phase: flow.phase),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ArtisanVerification verification,
    VerificationFlowState flow,
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
    } else if (flow.phase == VerificationFlowPhase.notConfigured) {
      body = const _NotAvailableCard();
    } else {
      body = _buildStart(verification, flow);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: body,
      ),
    );
  }

  Widget _buildStart(
    ArtisanVerification verification,
    VerificationFlowState flow,
  ) {
    final isRetry = verification.status == VerificationStatus.failed;
    final attempts = verification.attemptsRemaining;
    return Column(
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
            "You'll enter your NIN and take a quick live selfie in a secure "
            'window from our verification partner, Dojah. You can keep '
            'taking jobs while we check.',
            size: BodySize.medium,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 20.h),
        ],
        const _TrustNote(),
        if (flow.notice != null) ...[
          SizedBox(height: 16.h),
          _Banner(message: flow.notice!, isError: false),
        ],
        if (flow.message != null) ...[
          SizedBox(height: 16.h),
          _Banner(message: flow.message!, isError: true),
          if (flow.needsSettings) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: openAppSettings,
                child: BodyText(
                  'Open settings',
                  size: BodySize.medium,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
        SizedBox(height: 24.h),
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: flow.isBusy ? null : _startVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: BodyText(
              isRetry ? 'Try again' : 'Verify with Dojah',
              size: BodySize.medium,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: BodyText(
            attempts == 1
                ? '1 attempt left. Each try uses one attempt.'
                : '$attempts attempts left. Each try uses one attempt.',
            size: BodySize.small,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _TrustNote extends StatelessWidget {
  const _TrustNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 16.r, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: BodyText(
            'Your NIN and selfie go to Dojah, not to Workchop. We keep at '
            'most the last 4 digits of your NIN.',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NotAvailableCard extends StatelessWidget {
  const _NotAvailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.construction_outlined,
                size: 22.r,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: BodyText(
                  'Not available yet',
                  size: BodySize.large,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          BodyText(
            verificationNotConfiguredMessage,
            size: BodySize.medium,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;

  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.info;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              size: 18.r,
              color: color,
            ),
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

class _BusyOverlay extends StatelessWidget {
  final VerificationFlowPhase phase;

  const _BusyOverlay({required this.phase});

  @override
  Widget build(BuildContext context) {
    final title = phase == VerificationFlowPhase.confirming
        ? 'Confirming your result'
        : 'Getting things ready';
    final detail = phase == VerificationFlowPhase.confirming
        ? 'This usually takes a few seconds. Please keep the app open.'
        : 'Opening secure verification. Please keep the app open.';
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
                    title,
                    size: BodySize.large,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  BodyText(
                    detail,
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
