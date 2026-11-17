import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/network/dio_client.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/auth_session_service.dart';
import 'core/models/user.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/session_reset.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Reports uncaught Flutter and platform errors to Crashlytics in release and
/// profile builds. Debug builds keep errors in the console only.
Future<void> _initCrashReporting() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initCrashReporting();
  DioClient().init();
  try {
    await PushNotificationService.instance.initialize();
  } catch (error, stack) {
    // Push is optional: a failure here (missing entitlement, no network, ...)
    // must never leave the user with a blank screen.
    FirebaseCrashlytics.instance.recordError(error, stack);
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<String>? _forcedLogoutSub;
  ProviderSubscription<AsyncValue<User?>>? _signedOutSub;

  @override
  void initState() {
    super.initState();
    // One exit path for every way a session can end (Logout button, account
    // deletion, 401 forced logout): the moment a signed-in user becomes
    // signed-out, land on the login screen. Provider cleanup is handled by
    // sessionResetProvider.
    _signedOutSub = ref.listenManual<AsyncValue<User?>>(authProvider, (
      previous,
      next,
    ) {
      final wasSignedIn = previous?.value != null;
      final isSignedOut =
          !next.isLoading && next.hasValue && next.value == null;
      if (wasSignedIn && isSignedOut) {
        ref.read(routerProvider).go(AppRoutes.login);
      }
    });

    _forcedLogoutSub = AuthSessionService.instance.forcedLogoutStream.listen((
      _,
    ) async {
      if (ref.read(authProvider).value != null) {
        // Same cleanup as a normal logout, minus the backend call (the server
        // just told us the token is no good).
        await ref.read(authProvider.notifier).endSessionLocally();
      } else {
        // Nobody signed in (e.g. a 401 on the login form): just re-read the
        // stored session so state matches the cleared storage.
        ref.invalidate(authProvider);
      }
      if (!mounted) return;
      ref.read(routerProvider).go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _signedOutSub?.close();
    _forcedLogoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.watch(sessionResetProvider);
    PushNotificationService.instance.attachRouter(router);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      ensureScreenSize: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Workchop',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
