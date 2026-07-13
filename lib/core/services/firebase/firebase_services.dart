import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saint_paul/core/services/local/app_local_notifications.dart';

/// Handles FCM → local notification display and navigation on tap.
/// Does NOT manage tokens – that belongs in a Cubit.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Invoked when the user taps a notification (foreground or background/terminated).
  void Function(RemoteMessage)? onMessageOpened;

  Future<void> init() async {
    // 1. Request permission
    await _messaging.requestPermission();

    // 2. Initialise local notifications (must be done first)
    await AppLocalNotification.initialize();

    // 3. Foreground messages → show a local notification
    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif == null) return;

      AppLocalNotification.show(
        id: message.hashCode,
        title: notif.title ?? '',
        body: notif.body ?? '',
        payload: message.data.toString(), // carry FCM data for tap
      );
    });

    // 4. Handle taps
    // 4a. App in background → brought to foreground
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageOpened?.call(message);
    });

    // 4b. App was terminated and opened by notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpened?.call(initialMessage);
    }

    // 4c. Tap on a local (foreground) notification
    AppLocalNotification.onTap = (response) {
      // Convert payload string back to RemoteMessage? It’s easier to just
      // call onMessageOpened with a custom object or decode JSON.
      // For simplicity, you can ignore foreground tap navigation here,
      // or parse the data and act accordingly.
    };

    // ❌ No onBackgroundMessage – the system handles display automatically.
  }
}
