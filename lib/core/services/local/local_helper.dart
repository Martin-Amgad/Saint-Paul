import 'dart:convert';
import 'dart:developer';

import 'package:saint_paul/core/models/student_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static late SharedPreferences prefrences;

  static String KUserData = 'user_data';
  static String KEmail = 'email';
  static String Kotp = 'otp';
  static String KUserId = 'user_id';
  static String KUserType = 'user_type';
  static String KUserGroup = 'user_group';
  static String KIsNewUser = 'isNewUser';
  static String KStudyLevel = 'user_study_level';

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

  static Future<void> setUserGroup(String type) async {
    await prefrences.setString(KUserGroup, type);
  }

  static String? getUserGroup() {
    return prefrences.getString(KUserGroup);
  }

  static Future<void> setUserId(String userId) async {
    await prefrences.setString(KUserId, userId);
  }

  static String? getUserId() {
    return prefrences.getString(KUserId);
  }

  static Future<void> setIsNewUser(bool isNewUser) async {
    await prefrences.setBool(KIsNewUser, isNewUser);
  }

  static bool? getIsNewUser() {
    return prefrences.getBool(KIsNewUser);
  }

  static Future<void> setUserStudyLevel(String studyLevel) async {
    await prefrences.setString(KStudyLevel, studyLevel);
  }

  static String? getUserStudyLevel() {
    return prefrences.getString(KStudyLevel);
  }

  // Local storage → use toJsonLocal() and fromJsonLocal()
  static Future<void> setUserData(Map<String, dynamic>? userData) async {
    try {
      String dataString = jsonEncode(userData);
      await prefrences.setString(KUserData, dataString);
      log('✅ User data saved successfully');
    } catch (e) {
      log('❌ setUserData failed: $e');
    }
  }

  static StudentModel? getUserData() {
    String? dataString = prefrences.getString(KUserData);
    if (dataString != null) {
      return StudentModel.fromJsonLocal(
        jsonDecode(dataString),
        LocalHelper.getUserId() ?? '',
      );
    }
    return null;
  }
}
