import 'dart:convert';
import 'dart:developer';

import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static late SharedPreferences preferences;

  static String KStudentData = 'student_data';
  static String KEmail = 'email';
  static String Kotp = 'otp';
  static String KUserId = 'user_id';
  static String KUserType = 'user_type';
  static String KUserGroup = 'user_group';
  static String KIsNewUser = 'isNewUser';
  static String KStudyLevel = 'user_study_level';
  static String KallBadges = 'all_badges';
  static String KmyBadges = 'my_badges';
  static String KTeacherName = 'teacher_name';
  static String KTeacherData = 'teacher_data';
  static String KUserFamily = 'user_family';
  static String KUserChurch = 'user_church';
  static String KUserRole = 'user_role';
  static String KFCMToken = 'fcm_token';
  static String badgeNamesKey = 'badge_names_map';

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    return preferences.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await preferences.setString(key, value);
  }

  static Future<void> setUserType(String type) async {
    await preferences.setString(KUserType, type);
  }

  static String? getUserType() {
    return preferences.getString(KUserType);
  }

  static Future<void> setUserGroup(String type) async {
    await preferences.setString(KUserGroup, type);
  }

  static String? getUserGroup() {
    return preferences.getString(KUserGroup);
  }

  static Future<void> setUserId(String userId) async {
    await preferences.setString(KUserId, userId);
  }

  static String? getUserId() {
    return preferences.getString(KUserId);
  }

  static Future<void> setIsNewUser(bool isNewUser) async {
    await preferences.setBool(KIsNewUser, isNewUser);
  }

  static bool? getIsNewUser() {
    return preferences.getBool(KIsNewUser);
  }

  static Future<void> setUserStudyLevel(String studyLevel) async {
    await preferences.setString(KStudyLevel, studyLevel);
  }

  static String? getUserStudyLevel() {
    return preferences.getString(KStudyLevel);
  }

  // Local storage → use toJsonLocal() and fromJsonLocal()
  static Future<void> setStudentData(Map<String, dynamic>? userData) async {
    try {
      String dataString = jsonEncode(userData);
      await preferences.setString(KStudentData, dataString);
      log('✅ Student data saved successfully');
    } catch (e) {
      log('❌ setStudentData failed: $e');
    }
  }

  static StudentModel? getStudentData() {
    String? dataString = preferences.getString(KStudentData);
    if (dataString != null) {
      return StudentModel.fromJsonLocal(
        jsonDecode(dataString),
        LocalHelper.getUserId() ?? '',
      );
    }
    return null;
  }

  static Future<void> setAllBadges(List<BadgeModel> badges) async {
    try {
      final jsonList = badges.map((b) => b.toJson()).toList();
      await preferences.setString(KallBadges, jsonEncode(jsonList));
      log('✅ Badges saved as list');
    } catch (e) {
      log('❌ setAllBadges failed: $e');
    }
  }

  static List<BadgeModel> getAllBadges() {
    try {
      final dataString = preferences.getString(KallBadges);
      if (dataString != null) {
        final List<dynamic> decoded = jsonDecode(dataString);
        return decoded
            .asMap()
            .entries
            .map(
              (entry) => BadgeModel.fromJson(
                entry.value as Map<String, dynamic>,
                '', // local storage has no Firestore ID – use empty string or store id in JSON
              ),
            )
            .toList();
      }
    } catch (e) {
      log('❌ getAllBadges failed: $e');
    }
    return [];
  }

  static Future<void> setMyBadges(Map<String, dynamic> myBadges) async {
    try {
      String dataString = jsonEncode(myBadges);
      await preferences.setString(KmyBadges, dataString);
      log('✅ My badges saved successfully');
    } catch (e) {
      log('❌ setMyBadges failed: $e');
    }
  }

  static Map<String, String>? getMyBadges() {
    try {
      String? dataString = preferences.getString(KmyBadges);
      if (dataString != null) {
        Map<String, dynamic> badgesMap = jsonDecode(dataString);
        return badgesMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      log('❌ getMyBadges failed: $e');
    }
    return null;
  }

  static Future<void> setTeacherName(String name) async {
    await preferences.setString(KTeacherName, name);
  }

  static String? getTeacherName() {
    return preferences.getString(KTeacherName);
  }

  static Future<void> setTeacherData(TeacherModel teacher) async {
    final data = {
      'uid': teacher.uid,
      'name': teacher.name,
      'church': teacher.church,
      'adminPin': teacher.adminPin,
    };
    await preferences.setString(KTeacherData, jsonEncode(data));
  }

  static TeacherModel? getTeacherData() {
    final string = preferences.getString(KTeacherData);
    if (string == null) return null;
    final map = jsonDecode(string) as Map<String, dynamic>;
    return TeacherModel(
      uid: map['uid'],
      name: map['name'],
      church: map['church'],
      adminPin: map['adminPin'],
    );
  }

  static String? getUserFamily() {
    return preferences.getString(KUserFamily);
  }

  static Future<void> setUserFamily(String family) async {
    await preferences.setString(KUserFamily, family);
  }

  static String? getUserChurchName() {
    return preferences.getString(KUserChurch);
  }

  static Future<void> setUserChurchName(String churchName) async {
    await preferences.setString(KUserChurch, churchName);
  }

  static String? getUserRole() {
    return preferences.getString(KUserRole);
  }

  static Future<void> setUserRole(String role) async {
    await preferences.setString(KUserRole, role);
  }

  static String? getFCMToken() {
    return preferences.getString(KFCMToken);
  }

  static Future<void> setFCMToken(String token) async {
    await preferences.setString(KFCMToken, token);
  }

  static Future<void> removeFCMToken() async {
    await preferences.remove(KFCMToken);
  }

  static Future<void> setBadgeNamesMap(Map<String, String> map) async {
    try {
      await preferences.setString(badgeNamesKey, jsonEncode(map));
      log('✅ Badge names map saved');
    } catch (e) {
      log('❌ setBadgeNamesMap failed: $e');
    }
  }

  static Map<String, String> getBadgeNamesMap() {
    try {
      final dataString = preferences.getString(badgeNamesKey);
      if (dataString != null) {
        final Map<String, dynamic> decoded = jsonDecode(dataString);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      log('❌ getBadgeNamesMap failed: $e');
    }
    return {};
  }
}
