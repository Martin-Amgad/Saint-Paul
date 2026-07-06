import 'dart:convert';
import 'dart:developer';

import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHelper {
  static late SharedPreferences prefrences;

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
  static Future<void> setStudentData(Map<String, dynamic>? userData) async {
    try {
      String dataString = jsonEncode(userData);
      await prefrences.setString(KStudentData, dataString);
      log('✅ Student data saved successfully');
    } catch (e) {
      log('❌ setStudentData failed: $e');
    }
  }

  static StudentModel? getStudentData() {
    String? dataString = prefrences.getString(KStudentData);
    if (dataString != null) {
      return StudentModel.fromJsonLocal(
        jsonDecode(dataString),
        LocalHelper.getUserId() ?? '',
      );
    }
    return null;
  }

  static Future<void> setAllBadges(Map<String, dynamic> badges) async {
    try {
      String dataString = jsonEncode(badges);
      await prefrences.setString(KallBadges, dataString);
      log('✅ All badges saved successfully');
    } catch (e) {
      log('❌ setAllBadges failed: $e');
    }
  }

  static Map<String, String>? getAllBadges() {
    try {
      String? dataString = prefrences.getString(KallBadges);
      if (dataString != null) {
        Map<String, dynamic> badgesMap = jsonDecode(dataString);
        return badgesMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      log('❌ getAllBadges failed: $e');
    }
    return null;
  }

  static Future<void> setMyBadges(Map<String, dynamic> myBadges) async {
    try {
      String dataString = jsonEncode(myBadges);
      await prefrences.setString(KmyBadges, dataString);
      log('✅ My badges saved successfully');
    } catch (e) {
      log('❌ setMyBadges failed: $e');
    }
  }

  static Map<String, String>? getMyBadges() {
    try {
      String? dataString = prefrences.getString(KmyBadges);
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
    await prefrences.setString(KTeacherName, name);
  }

  static String? getTeacherName() {
    return prefrences.getString(KTeacherName);
  }

  static Future<void> setTeacherData(TeacherModel teacher) async {
    final data = {
      'uid': teacher.uid,
      'name': teacher.name,
      'church': teacher.church,
      'adminPin': teacher.adminPin,
    };
    await prefrences.setString(KTeacherData, jsonEncode(data));
  }

  static TeacherModel? getTeacherData() {
    final string = prefrences.getString(KTeacherData);
    if (string == null) return null;
    final map = jsonDecode(string) as Map<String, dynamic>;
    return TeacherModel(
      uid: map['uid'],
      name: map['name'],
      church: map['church'],
      adminPin: map['adminPin'],
    );
  }
}
