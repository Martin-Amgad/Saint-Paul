import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Pure helper for local notifications – no FCM logic.
class AppLocalNotification {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Callback for when the user taps a locally shown notification (foreground).
  static void Function(NotificationResponse)? onTap;

  /// Must be called once before any notifications are shown (e.g. in main).
  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response);
      },
    );

    // Create a proper notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      'fcm_general', // id
      'إشعارات عامة', // user‑visible name
      description: 'تنبيهات من تطبيق خدمة القديس بولس',
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Shows an immediate local notification.
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload, // used to pass data for tap handling
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'fcm_general',
        'إشعارات عامة',
        icon: 'ic_notification', // your custom white silhouette
        color: Color(0xFF00897B), // your colorAccent (example)
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
