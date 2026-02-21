import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static late SharedPreferences prefrences;

  static String KUserData = 'user_data';
  static String KEmail = 'email';
  static String Kotp = 'otp';
  static String KUserType = 'usertype';
  static String KIsNewUser = 'isNewUser';

  static Future<void> init() async {
    prefrences = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    return prefrences.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await prefrences.setString(key, value);
  }

  static Future<void> setUserType(String type) async {
    await prefrences.setString(KUserType, type);
  }

  static String? getUserType() {
    return prefrences.getString(KUserType);
  }

  static Future<void> setUserId(String userId) async {
    await prefrences.setString(KUserData, userId);
  }

  static String? getUserId() {
    return prefrences.getString(KUserData);
  }

  static Future<void> setIsNewUser(bool isNewUser) async {
    await prefrences.setBool(KIsNewUser, isNewUser);
  }

  static bool? getIsNewUser() {
    return prefrences.getBool(KIsNewUser);
  }
}
