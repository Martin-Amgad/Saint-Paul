// lib/repositories/fcm_token_repo.dart
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class FCMTokenRepo {
  static Future<void> saveToken(String uid, String token) async {
    final oldToken = LocalHelper.getFCMToken();

    // Delete old token document if token changed
    if (oldToken != null && oldToken != token) {
      await FirebaseProvider.deleteFCMToken(oldToken);
    }

    // Save new token to Firestore
    await FirebaseProvider.saveFCMToken(uid: uid, token: token);

    // Cache it locally for later comparisons
    await LocalHelper.setFCMToken(token);
  }

  static Future<void> deleteToken() async {
    final currentToken = LocalHelper.getFCMToken();
    if (currentToken != null) {
      await FirebaseProvider.deleteFCMToken(currentToken);
      await LocalHelper.removeFCMToken();
    }
  }
}
