import 'dart:developer';

import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

class HomeRepo {
  static Future<String?> updatStudent(
    StudentModel student,
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  ) async {
    try {
      log('Updating student with ID: ${student.uid}');
      log('New Tayo Categories: $tayoNewCategories');
      log('Removed Tayo Categories: $tayoRemovedCategories');
      // THEN update all documents with additions/removals
      if ((tayoNewCategories?.isEmpty ?? true) &&
          (tayoRemovedCategories?.isEmpty ?? true)) {
        await FirebaseProvider.updateStudent(student);
        return 'تم تحديث بيانات المخدوم بنجاح.';
      }
      await FirebaseProvider.updateTayoInAllDocuments(
        tayoNewCategories,
        tayoRemovedCategories,
      );
      await FirebaseProvider.updateStudent(student);
      tayoNewCategories = [];
      tayoRemovedCategories = [];

      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      throw Exception('Failed to update student: ${e.toString()}');
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<Map<String, dynamic>?> getStudentTayoDetails(
    StudentModel student,
  ) async {
    try {
      final snapshot = await FirebaseProvider.getStudentByID(student.uid ?? '');

      final data = ((snapshot.data()) as Map<String, dynamic>?) ?? {};

      return data['tayo'] as Map<String, dynamic>? ?? {};
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<String?> createStudent(StudentModel student) async {
    try {
      await FirebaseProvider.createStudent(student);
      return 'تم إنشاء المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إنشاء المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> updatStudentTakenAt(StudentModel student) async {
    try {
      await FirebaseProvider.updateStudent(student);
      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> loadStudentYear(String? id) async {
    try {
      if (id == null || id.isEmpty) {
        return 'ثالثة اعدادي';
      }
      final snapshot = await FirebaseProvider.getStudentByID(id);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data['studyLevel'] as String?;
    } on Exception catch (e) {
      log(e.toString());
      return 'ثالثة اعدادي';
    }
  }

  static Future<StudentModel?> loadStudentData(String? id) async {
    try {
      final snapshot = await FirebaseProvider.getStudentByID(id);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final student = StudentModel.fromJson(data, snapshot.id);
      return student;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<void> updateStudentGroup(
    String studentGroupId,
    int changesToTotalTayo,
  ) async {
    try {
      log(
        'Updating student group with ID: $studentGroupId, changes to total tayo: $changesToTotalTayo',
      );
      var snapshot = await FirebaseProvider.getGroupbyId(studentGroupId);
      if (snapshot.exists) {
        var group = GroupModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        log(
          'Fetched group: ${group.gid} → ${group.name} with total tayo: ${group.totalTayo}',
        );
        await FirebaseProvider.updateGroup(
          group.copyWith(
            totalTayo: (group.totalTayo ?? 0) + changesToTotalTayo,
          ),
        );
        log(
          'Updated group total tayo to: ${(group.totalTayo ?? 0) + changesToTotalTayo}',
        );
      }
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('Failed to update student group: ${e.toString()}');
    }
  }
}
