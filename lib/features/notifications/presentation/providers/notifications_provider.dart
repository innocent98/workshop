import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_remote_datasource.dart';
import '../../domain/models/app_notification.dart';

final notificationsDataSourceProvider = Provider<NotificationsRemoteDataSource>(
  (ref) => NotificationsRemoteDataSource(),
);

final notificationsProvider = FutureProvider<NotificationListResult>((
  ref,
) async {
  final dataSource = ref.watch(notificationsDataSourceProvider);
  return dataSource.listNotifications(page: 1, pageSize: 50);
});
