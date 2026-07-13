// lib/core/services/firebase/fcm_token_manager.dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saint_paul/feature/Notifications/data/fcm_token_repo.dart';

class FCMTokenManager {
  static StreamSubscription<String>? _refreshSubscription;
  static bool _isListenerActive = false;

  /// Start listening for token refreshes and save new tokens automatically.
  static void init(String uid) {
    if (_isListenerActive) return;

    _refreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((
      newToken,
    ) async {
      await FCMTokenRepo.saveToken(uid, newToken);
    });
    _isListenerActive = true;
  }

  /// Cancel the listener (call on logout).
  static void dispose() {
    _refreshSubscription?.cancel();
    _refreshSubscription = null;
    _isListenerActive = false;
  }
}
