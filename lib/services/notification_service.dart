import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // flutter_local_notifications is not supported on web
    if (kIsWeb) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String channelId = 'general',
    String? payload,
  }) async {
    if (kIsWeb) return;

    String channelName = 'General';
    String description = 'General Notifications';

    if (channelId == 'chat_messages') {
      channelName = 'Chat Messages';
      description = 'Notifications for new chat messages';
    } else if (channelId == 'service_leads') {
      channelName = 'Service Leads';
      description = 'Notifications for new service job requests';
    } else if (channelId == 'referral_rewards') {
      channelName = 'Referral Rewards';
      description = 'Notifications for referral signups and credits';
    } else if (channelId == 'local_deals') {
      channelName = 'Local Deals';
      description = 'Notifications for new deals and offers';
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: description,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> cancelNotificationsForConversation(String conversationId) async {
    if (kIsWeb) return;
    // We use a simple hash of the conversationId as the notification ID
    final int id = conversationId.hashCode;
    await _plugin.cancel(id);
  }
}
