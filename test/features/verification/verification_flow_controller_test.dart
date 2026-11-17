import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/verification/domain/dojah_widget_launcher.dart';
import 'package:workchop/features/verification/domain/models/artisan_verification.dart';
import 'package:workchop/features/verification/domain/models/dojah_widget_config.dart';
import 'package:workchop/features/verification/domain/models/verification_api_exception.dart';
import 'package:workchop/features/verification/domain/models/verification_start.dart';
import 'package:workchop/features/verification/domain/models/verification_status.dart';
import 'package:workchop/features/verification/domain/repositories/verification_repository.dart';
import 'package:workchop/features/verification/domain/verification_error_messages.dart';
import 'package:workchop/features/verification/presentation/providers/verification_provider.dart';

const _usableConfig = DojahWidgetConfig(
  configured: true,
  appId: 'capture-app-id',
  publicKey: 'capture-public-key',
  widgetId: 'capture-nin-widget',
  environment: 'sandbox',
);

const _start = VerificationStart(
  referenceId: 'WC-NIN-722d6ac501fca48c',
  widgetId: 'capture-nin-widget',
  email: 'artisan@example.com',
  attemptsRemaining: 4,
);

const _unverified = ArtisanVerification(status: VerificationStatus.unverified);

const _verified = ArtisanVerification(
  status: VerificationStatus.verified,
  isVerified: true,
  method: 'dojah',
  ninLast4: '1117',
  referenceId: 'WC-NIN-722d6ac501fca48c',
  attemptsUsed: 1,
  attemptsRemaining: 4,
);

const _pending = ArtisanVerification(
  status: VerificationStatus.pending,
  referenceId: 'WC-NIN-722d6ac501fca48c',
  attemptsUsed: 1,
  attemptsRemaining: 4,
);

class FakeRepo implements VerificationRepository {
  DojahWidgetConfig config = _usableConfig;
  Object? configError;
  Object? startError;
  ArtisanVerification? confirmResult;
  Object? confirmError;
  final List<ArtisanVerification> statuses = [_unverified];

  int configCalls = 0;
  int startCalls = 0;
  final List<String> confirmedReferences = [];
  int statusCalls = 0;

  @override
  Future<DojahWidgetConfig> getConfig() async {
    configCalls++;
    if (configError != null) throw configError!;
    return config;
  }

  @override
  Future<VerificationStart> start() async {
    startCalls++;
    if (startError != null) throw startError!;
    return _start;
  }

  @override
  Future<ArtisanVerification> confirm(String referenceId) async {
    confirmedReferences.add(referenceId);
    if (confirmError != null) throw confirmError!;
    return confirmResult!;
  }

  @override
  Future<ArtisanVerification> getStatus() async {
    final i = statusCalls < statuses.length ? statusCalls : statuses.length - 1;
    statusCalls++;
    return statuses[i];
  }
}

class FakeLauncher implements DojahWidgetLauncher {
  WidgetPermissionResult permission = WidgetPermissionResult.granted;
  DojahOutcome outcome = DojahOutcome.success;
  int launchCalls = 0;
  DojahLaunchParams? lastParams;

  @override
  Future<WidgetPermissionResult> ensurePermissions() async => permission;

  @override
  Future<DojahOutcome> launch(
    BuildContext context,
    DojahLaunchParams params,
  ) async {
    launchCalls++;
    lastParams = params;
    return outcome;
  }
}

class _Harness {
  final ProviderContainer container;
  final BuildContext context;
  _Harness(this.container, this.context);

  VerificationFlowState get flow => container.read(verificationFlowProvider);
  ArtisanVerification? get status =>
      container.read(verificationStatusProvider).value;

  Future<void> verify() =>
      container.read(verificationFlowProvider.notifier).verify(context);
}

Future<_Harness> _pump(
  WidgetTester tester,
  FakeRepo repo,
  FakeLauncher launcher,
) async {
  late BuildContext captured;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(repo),
        dojahWidgetLauncherProvider.overrideWithValue(launcher),
      ],
      child: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  final container = ProviderScope.containerOf(captured);
  // Auto-dispose providers need a listener to survive between calls.
  container.listen(verificationStatusProvider, (_, _) {});
  container.listen(verificationFlowProvider, (_, _) {});
  await container.read(verificationStatusProvider.future);
  return _Harness(container, captured);
}

void main() {
  testWidgets('success -> confirm -> verified', (tester) async {
    final repo = FakeRepo()..confirmResult = _verified;
    final launcher = FakeLauncher();
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(repo.startCalls, 1);
    expect(launcher.launchCalls, 1);
    expect(launcher.lastParams!.referenceId, 'WC-NIN-722d6ac501fca48c');
    expect(launcher.lastParams!.widgetId, 'capture-nin-widget');
    expect(launcher.lastParams!.email, 'artisan@example.com');
    expect(repo.confirmedReferences, ['WC-NIN-722d6ac501fca48c']);
    expect(h.status!.status, VerificationStatus.verified);
    expect(h.status!.ninLast4, '1117');
    expect(h.flow.phase, VerificationFlowPhase.idle);
    expect(h.flow.message, isNull);
  });

  testWidgets('success -> confirm failed is shown as failed, not pending', (
    tester,
  ) async {
    const failed = ArtisanVerification(
      status: VerificationStatus.failed,
      failureReason:
          'We could not verify this NIN. Check the number and try '
          'again.',
      attemptsUsed: 2,
      attemptsRemaining: 3,
    );
    final repo = FakeRepo()..confirmResult = failed;
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();

    expect(h.status!.status, VerificationStatus.failed);
    expect(h.status!.failureReason, failed.failureReason);
  });

  testWidgets('confirm 200 pending stays pending, then polling resolves it', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..confirmResult = _pending
      ..statuses.addAll([_verified]);
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();
    expect(h.status!.status, VerificationStatus.pending);

    // What the page's poller does on each tick.
    await h.container.read(verificationStatusProvider.notifier).fetchQuietly();
    expect(h.status!.status, VerificationStatus.verified);
    expect(repo.startCalls, 1, reason: 'polling must never start again');
  });

  testWidgets('confirm 502 provider_error -> pending -> poll -> verified', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..confirmError = ApiException('x', 502, 'provider_error')
      ..statuses.addAll([_verified]);
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();

    expect(
      h.status!.status,
      VerificationStatus.pending,
      reason: 'no false fail',
    );
    expect(h.status!.referenceId, 'WC-NIN-722d6ac501fca48c');
    expect(h.status!.attemptsRemaining, 4);
    expect(h.flow.message, isNull);

    await h.container.read(verificationStatusProvider.notifier).fetchQuietly();
    expect(h.status!.status, VerificationStatus.verified);
  });

  for (final entry in {
    'network error': NetworkException(),
    'unknown_reference 404': ApiException('x', 404, 'unknown_reference'),
    'unexpected exception': StateError('boom'),
  }.entries) {
    testWidgets('confirm ${entry.key} is treated as pending', (tester) async {
      final repo = FakeRepo()..confirmError = entry.value;
      final h = await _pump(tester, repo, FakeLauncher());

      await h.verify();

      expect(h.status!.status, VerificationStatus.pending);
      expect(h.flow.phase, VerificationFlowPhase.idle);
      expect(h.flow.message, isNull);
    });
  }

  testWidgets(
    'widget closed -> back to idle, attempt-used notice, no confirm',
    (tester) async {
      final repo = FakeRepo();
      final launcher = FakeLauncher()..outcome = DojahOutcome.closed;
      final h = await _pump(tester, repo, launcher);

      await h.verify();

      expect(h.flow.phase, VerificationFlowPhase.idle);
      expect(h.flow.message, isNull);
      expect(h.flow.notice, verificationClosedEarlyMessage(4));
      expect(h.flow.notice, contains('has been used'));
      expect(repo.confirmedReferences, isEmpty);
      expect(repo.startCalls, 1, reason: 'never auto-restart');
      expect(repo.statusCalls, 2, reason: 'initial load + one quiet re-sync');
    },
  );

  testWidgets('widget error -> failed-to-complete message', (tester) async {
    final repo = FakeRepo();
    final launcher = FakeLauncher()..outcome = DojahOutcome.error;
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.incomplete);
    expect(h.flow.message, verificationWidgetIncompleteMessage(4));
    expect(repo.confirmedReferences, isEmpty);
    expect(repo.startCalls, 1);
  });

  testWidgets('configured:false -> not configured, start never called', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..config = const DojahWidgetConfig(configured: false);
    final launcher = FakeLauncher();
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.notConfigured);
    expect(h.flow.message, verificationNotConfiguredMessage);
    expect(repo.startCalls, 0, reason: 'must not burn an attempt');
    expect(launcher.launchCalls, 0);
  });

  testWidgets('configured:true but missing widget id is also not usable', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..config = const DojahWidgetConfig(
        configured: true,
        appId: 'a',
        publicKey: 'k',
      );
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.notConfigured);
    expect(repo.startCalls, 0);
  });

  testWidgets('camera denied -> no config, no start, no attempt used', (
    tester,
  ) async {
    final repo = FakeRepo();
    final launcher = FakeLauncher()..permission = WidgetPermissionResult.denied;
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.error);
    expect(h.flow.message, verificationCameraDeniedMessage);
    expect(h.flow.needsSettings, isFalse);
    expect(repo.configCalls, 0);
    expect(repo.startCalls, 0);
  });

  testWidgets('camera blocked at OS level offers settings', (tester) async {
    final launcher = FakeLauncher()
      ..permission = WidgetPermissionResult.permanentlyDenied;
    final h = await _pump(tester, FakeRepo(), launcher);

    await h.verify();

    expect(h.flow.message, verificationCameraBlockedMessage);
    expect(h.flow.needsSettings, isTrue);
  });

  testWidgets('start 429 attempts_exhausted -> locked copy with retry time', (
    tester,
  ) async {
    final retryAt = DateTime.utc(2026, 11, 18, 12, 58);
    final repo = FakeRepo()
      ..startError = VerificationApiException(
        message: 'Too many verification attempts. Please try again later.',
        statusCode: 429,
        code: 'attempts_exhausted',
        retryAvailableAt: retryAt,
      )
      ..statuses.addAll([
        ArtisanVerification(
          status: VerificationStatus.failed,
          attemptsUsed: 5,
          attemptsRemaining: 0,
          retryAvailableAt: retryAt,
        ),
      ]);
    final launcher = FakeLauncher();
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.error);
    expect(h.flow.message, contains("You've used all your verification"));
    expect(launcher.launchCalls, 0);
    expect(repo.startCalls, 1);
    expect(h.status!.isLockedOut, isTrue, reason: 'status re-synced');
  });

  testWidgets('start 409 already_verified -> message and status re-sync', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..startError = ApiException('x', 409, 'already_verified')
      ..statuses.addAll([_verified]);
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();

    expect(h.flow.message, verificationErrorMessages['already_verified']);
    expect(h.status!.status, VerificationStatus.verified);
  });

  testWidgets('start 503 verification_unavailable keeps the page usable', (
    tester,
  ) async {
    final repo = FakeRepo()
      ..startError = ApiException('x', 503, 'verification_unavailable');
    final launcher = FakeLauncher();
    final h = await _pump(tester, repo, launcher);

    await h.verify();

    expect(h.flow.phase, VerificationFlowPhase.error);
    expect(
      h.flow.message,
      verificationErrorMessages['verification_unavailable'],
    );
    expect(launcher.launchCalls, 0);
  });

  testWidgets('offline while loading config -> offline copy, no start', (
    tester,
  ) async {
    final repo = FakeRepo()..configError = NetworkException();
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();

    expect(h.flow.message, verificationOfflineMessage);
    expect(repo.startCalls, 0);
  });

  testWidgets('each verify() starts at most once (no auto-restart)', (
    tester,
  ) async {
    final repo = FakeRepo()..confirmError = NetworkException();
    final h = await _pump(tester, repo, FakeLauncher());

    await h.verify();
    expect(repo.startCalls, 1);

    // A second, explicit user tap is a new attempt by design.
    await h.verify();
    expect(repo.startCalls, 2);
  });
}
