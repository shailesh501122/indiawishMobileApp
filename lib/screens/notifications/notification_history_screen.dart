import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../core/constants.dart';
import '../../models/notification_model.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<NotificationProvider>().fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<NotificationProvider>().markAllAsRead(),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIconColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getIcon(notification.type),
            color: _getIconColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt),
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
          _handleNotificationTap(context, notification);
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'listing':
        return Icons.sell_outlined;
      case 'booking':
        return Icons.event_available_outlined;
      case 'system':
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'chat':
        return Colors.blue;
      case 'listing':
        return Colors.green;
      case 'booking':
        return Colors.orange;
      case 'system':
      default:
        return AppColors.primary;
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Logic to navigate based on notification type and data
    if (notification.type == 'chat' &&
        notification.data.containsKey('conversation_id')) {
      // Navigate to chat
    }
  }
}
