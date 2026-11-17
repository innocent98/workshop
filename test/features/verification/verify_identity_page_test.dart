import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workchop/features/verification/domain/dojah_widget_launcher.dart';
import 'package:workchop/features/verification/domain/models/artisan_verification.dart';
import 'package:workchop/features/verification/domain/models/dojah_widget_config.dart';
import 'package:workchop/features/verification/domain/models/verification_start.dart';
import 'package:workchop/features/verification/domain/models/verification_status.dart';
import 'package:workchop/features/verification/domain/repositories/verification_repository.dart';
import 'package:workchop/features/verification/presentation/pages/verify_identity_page.dart';
import 'package:workchop/features/verification/presentation/providers/verification_provider.dart';

class _Repo implements VerificationRepository {
  final ArtisanVerification status;
  int startCalls = 0;
  _Repo(this.status);

  @override
  Future<ArtisanVerification> getStatus() async => status;

  @override
  Future<DojahWidgetConfig> getConfig() async => const DojahWidgetConfig(
    configured: true,
    appId: 'a',
    publicKey: 'k',
    widgetId: 'w',
  );

  @override
  Future<VerificationStart> start() async {
    startCalls++;
    return const VerificationStart(
      referenceId: 'WC-NIN-0000000000000000',
      widgetId: 'w',
      attemptsRemaining: 3,
    );
  }

  @override
  Future<ArtisanVerification> confirm(String referenceId) async => status;
}

class _Launcher implements DojahWidgetLauncher {
  int launches = 0;

  @override
  Future<WidgetPermissionResult> ensurePermissions() async =>
      WidgetPermissionResult.granted;

  @override
  Future<DojahOutcome> launch(
    BuildContext context,
    DojahLaunchParams params,
  ) async {
    launches++;
    return DojahOutcome.closed;
  }
}

Future<(_Repo, _Launcher)> _pumpPage(
  WidgetTester tester,
  ArtisanVerification status,
) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final repo = _Repo(status);
  final launcher = _Launcher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(repo),
        dojahWidgetLauncherProvider.overrideWithValue(launcher),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const MaterialApp(home: VerifyIdentityPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return (repo, launcher);
}

void main() {
  testWidgets('unverified: intro, Dojah trust copy, button, attempts left', (
    tester,
  ) async {
    final (repo, launcher) = await _pumpPage(
      tester,
      const ArtisanVerification(status: VerificationStatus.unverified),
    );

    expect(find.text('Verify with Dojah'), findsOneWidget);
    expect(find.textContaining('go to Dojah, not to Workchop'), findsOneWidget);
    expect(find.textContaining('5 attempts left'), findsOneWidget);
    // Nothing is started just by opening the screen.
    expect(repo.startCalls, 0);

    await tester.ensureVisible(find.text('Verify with Dojah'));
    await tester.pump();
    await tester.tap(find.text('Verify with Dojah'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(repo.startCalls, 1);
    expect(launcher.launches, 1);
    expect(find.textContaining('has been used'), findsOneWidget);
  });

  testWidgets('failed: reason verbatim, attempts left, Try again', (
    tester,
  ) async {
    const reason =
        'We could not verify this NIN. Check the number and try again.';
    await _pumpPage(
      tester,
      const ArtisanVerification(
        status: VerificationStatus.failed,
        failureReason: reason,
        attemptsUsed: 2,
        attemptsRemaining: 3,
      ),
    );

    expect(find.text(reason), findsOneWidget);
    expect(
      find.textContaining('3 attempts left in the next 24'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Verify with Dojah'), findsNothing);
  });

  testWidgets('locked out: no start button', (tester) async {
    await _pumpPage(
      tester,
      ArtisanVerification(
        status: VerificationStatus.failed,
        failureReason: 'No match',
        attemptsUsed: 5,
        attemptsRemaining: 0,
        retryAvailableAt: DateTime.now().add(const Duration(hours: 5)),
      ),
    );

    expect(find.text('No attempts left for now'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Verify with Dojah'), findsNothing);
  });
}
