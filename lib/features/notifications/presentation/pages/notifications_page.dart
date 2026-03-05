import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refresh(ref);
    });
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(notificationsProvider);
    await ref.read(notificationsProvider.future);
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const BodyText(
          'Notifications',
          size: BodySize.medium,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationsDataSourceProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
            },
            child: const BodyText(
              'Mark all read',
              size: BodySize.small,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (result) {
          if (result.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: BodyText(
                      'No notifications yet.',
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemBuilder: (context, index) {
                final notification = result.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  trailingText: _timeAgo(notification.createdAt),
                  onTap: () async {
                    if (!notification.isRead) {
                      await ref
                          .read(notificationsDataSourceProvider)
                          .markAsRead(notification.id);
                      ref.invalidate(notificationsProvider);
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemCount: result.notifications.length,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BodyText(
                  'Unable to load notifications.',
                  size: BodySize.medium,
                  color: AppColors.error,
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => ref.invalidate(notificationsProvider),
                  child: const BodyText(
                    'Retry',
                    size: BodySize.small,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final String trailingText;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                margin: EdgeInsets.only(top: 5.h, right: 8.w),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.textSecondary.withValues(alpha: 0.35)
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      notification.title,
                      size: BodySize.small,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 3.h),
                    BodyText(
                      notification.body,
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              BodyText(
                trailingText,
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
