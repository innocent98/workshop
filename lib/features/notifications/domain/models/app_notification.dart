class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? eventType;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.eventType,
    this.payload,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      eventType: json['event_type'] as String?,
      payload: (json['payload'] as Map?)?.cast<String, dynamic>(),
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }
}

class NotificationListResult {
  final List<AppNotification> notifications;
  final int total;
  final int unreadCount;
  final int page;
  final int pageSize;

  const NotificationListResult({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.pageSize,
  });

  factory NotificationListResult.fromJson(Map<String, dynamic> json) {
    final items = (json['notifications'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
        .toList();
    return NotificationListResult(
      notifications: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? items.length,
    );
  }
}
