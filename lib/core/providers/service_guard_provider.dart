import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceGuardState {
  final bool hasCheckedThisSession;
  final bool hasServices;
  final String? userId;

  const ServiceGuardState({
    required this.hasCheckedThisSession,
    required this.hasServices,
    required this.userId,
  });

  const ServiceGuardState.initial()
    : hasCheckedThisSession = false,
      hasServices = false,
      userId = null;

  ServiceGuardState copyWith({
    bool? hasCheckedThisSession,
    bool? hasServices,
    String? userId,
  }) {
    return ServiceGuardState(
      hasCheckedThisSession:
          hasCheckedThisSession ?? this.hasCheckedThisSession,
      hasServices: hasServices ?? this.hasServices,
      userId: userId ?? this.userId,
    );
  }
}

class ServiceGuardNotifier extends Notifier<ServiceGuardState> {
  @override
  ServiceGuardState build() => const ServiceGuardState.initial();

  bool shouldReuseForUser(String userId) {
    return state.hasCheckedThisSession && state.userId == userId;
  }

  void setForUser({required String userId, required bool hasServices}) {
    state = ServiceGuardState(
      hasCheckedThisSession: true,
      hasServices: hasServices,
      userId: userId,
    );
  }

  void clear() {
    state = const ServiceGuardState.initial();
  }
}

final serviceGuardProvider =
    NotifierProvider<ServiceGuardNotifier, ServiceGuardState>(
      ServiceGuardNotifier.new,
    );
