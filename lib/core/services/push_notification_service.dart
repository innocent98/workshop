import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/dio_client.dart';
import 'token_storage_service.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final TokenStorageService _tokenStorage = TokenStorageService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  GoRouter? _router;

  bool _initialized = false;
  bool _initialMessageHandled = false;
  RemoteMessage? _pendingInitialMessage;
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'workchop_realtime',
    'Workchop Realtime',
    description: 'Realtime booking and payment notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission();
    await _messaging.setAutoInitEnabled(true);
    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen((message) async {
      await _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationOpen(message);
    });

    _messaging.onTokenRefresh.listen((token) {
      _registerToken(token);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingInitialMessage = initialMessage;
      _tryHandleInitialMessage();
    }

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }
  }

  void attachRouter(GoRouter router) {
    _router = router;
    _tryHandleInitialMessage();
  }

  void _tryHandleInitialMessage() {
    if (_initialMessageHandled) return;
    if (_router == null) return;
    final message = _pendingInitialMessage;
    if (message == null) return;
    _initialMessageHandled = true;
    _handleNotificationOpen(message);
  }

  void _handleNotificationOpen(RemoteMessage message) {
    final route = _resolveRouteFromData(message.data);
    if (route == null) return;
    _router?.go(route);
  }

  void _handleNotificationOpenFromData(Map<String, dynamic> data) {
    final route = _resolveRouteFromData(data);
    if (route == null) return;
    _router?.go(route);
  }

  String? _resolveRouteFromData(Map<String, dynamic> data) {
    final event = (data['event'] ?? '').toString();
    switch (event) {
      case 'booking_created':
      case 'payment_success':
      case 'completion_confirmed':
      case 'booking_cancelled':
      case 'payment_released':
        return '/artisan-home?tab=jobs';
      case 'booking_accepted':
      case 'booking_rejected':
      case 'booking_started':
      case 'booking_completed':
      case 'progress_logged':
        return '/client-home';
      default:
        return '/';
    }
  }

  Future<void> syncTokenToBackend() async {
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }
  }

  Future<void> unregisterCurrentToken() async {
    // Best effort end to end: on the iOS simulator (or any device without an
    // APNs token) `getToken()` throws, and that must never block logout.
    try {
      final hasAuth = await _tokenStorage.hasToken();
      if (!hasAuth) return;

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await DioClient().dio.post(
        '/notifications/devices/unregister',
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Best effort only
    }
  }

  Future<void> _registerToken(String token) async {
    final hasAuth = await _tokenStorage.hasToken();
    if (!hasAuth) return;

    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
        ? 'ios'
        : 'web';

    try {
      await DioClient().dio.post(
        '/notifications/devices/register',
        data: {'fcm_token': token, 'platform': platform},
      );
    } catch (_) {
      // Best effort only
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // Permission is requested once through FirebaseMessaging above; asking
    // again here would show a second system prompt on iOS.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          _handleNotificationOpenFromData(data);
        } catch (_) {}
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Workchop';
    final body = message.notification?.body ?? 'You have a new update';
    final payload = jsonEncode(message.data);

    const androidDetails = AndroidNotificationDetails(
      'workchop_realtime',
      'Workchop Realtime',
      channelDescription: 'Realtime booking and payment notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
