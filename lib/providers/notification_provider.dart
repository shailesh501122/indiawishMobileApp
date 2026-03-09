import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getNotifications();
      _notifications = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error in NotificationProvider.fetchNotifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final success = await _apiService.markNotificationAsRead(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          data: _notifications[index].data,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _apiService.markAllNotificationsAsRead();
    if (success) {
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      notifyListeners();
    }
  }
}
