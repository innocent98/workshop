import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/app_notification.dart';

class NotificationsRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<NotificationListResult> listNotifications({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return NotificationListResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/read-all');
  }
}
