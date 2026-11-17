import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_notification_service.dart';

/// The two push-token operations the auth flow needs. Kept behind an interface
/// so auth state can be tested without Firebase being initialised.
abstract class PushTokenGateway {
  /// Registers the current device token with the backend (needs a session).
  Future<void> sync();

  /// Detaches this device from the signed-in account (needs a session).
  Future<void> unregister();
}

class FirebasePushTokenGateway implements PushTokenGateway {
  const FirebasePushTokenGateway();

  @override
  Future<void> sync() => PushNotificationService.instance.syncTokenToBackend();

  @override
  Future<void> unregister() =>
      PushNotificationService.instance.unregisterCurrentToken();
}

final pushTokenGatewayProvider = Provider<PushTokenGateway>(
  (ref) => const FirebasePushTokenGateway(),
);
