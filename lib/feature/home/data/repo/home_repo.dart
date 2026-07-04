import 'dart:developer';
import 'dart:io';

import 'package:saint_paul/core/extentions/image_uploader.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class HomeRepo {
  static Future<String?> updatStudent({
    required StudentModel newStudent,
    required StudentModel oldStudent,
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  }) async {
    try {
      final historyChanges = computeTayoChanges(
        oldTayo: oldStudent.tayo!,
        newTayo: newStudent.tayo!,
        removedCategories: tayoRemovedCategories ?? [],
      );

      log('Updating student with ID: ${newStudent.uid}');
      log('New Tayo Categories: $tayoNewCategories');
      log('Removed Tayo Categories: $tayoRemovedCategories');

      // THEN update all documents with additions/removals
      if ((tayoNewCategories?.isEmpty ?? true) &&
          (tayoRemovedCategories?.isEmpty ?? true)) {
        await FirebaseProvider.updateStudent(newStudent);

        return 'تم تحديث بيانات المخدوم بنجاح.';
      }

      await FirebaseProvider.updateTayoInAllDocuments(
        tayoNewCategories,
        tayoRemovedCategories,
      );

      await FirebaseProvider.updateStudent(newStudent);

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
        return ' ';
      }
      final snapshot = await FirebaseProvider.getStudentByID(id);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data['studyLevel'] as String?;
    } on Exception catch (e) {
      log(e.toString());
      return ' ';
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

  static Future<String?> uploadBadgeImageToCloudinary(
    String badgeName,
    String path,
  ) async {
    try {
      final cloudinaryUrl = await uploadImageToCloudinary(File(path));
      if (cloudinaryUrl == null) return null;
      log('Cloudinary URL: $cloudinaryUrl');

      return cloudinaryUrl; // ← return URL not Arabic string
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<Map<String, String>> getCurrentBadges() async {
    try {
      final badges = await FirebaseProvider.getBadges();
      log('Fetched badges from Firebase: $badges');
      return badges;
    } catch (e) {
      log(e.toString());
      return <String, String>{};
    }
  }

  static Future<void> createBadgeInConfig(String badgeName, String url) async {
    try {
      await FirebaseProvider.createBadge(badgeName, url);
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('Failed to update badge in Firebase: ${e.toString()}');
    }
  }

  static List<TayoHistoryChange> computeTayoChanges({
    required Map<String, dynamic> oldTayo,
    required Map<String, dynamic> newTayo,
    required List<String> removedCategories,
  }) {
    final changes = <TayoHistoryChange>[];

    for (final entry in newTayo.entries) {
      final category = entry.key;
      final newData = entry.value;

      // 1. Skip deleted categories
      if (removedCategories.contains(category)) continue;

      // Extract count, defaulting to 0 if missing
      final newCount = (newData['count'] as int?) ?? 0;

      if (oldTayo.containsKey(category)) {
        // 2. Existing category
        final oldData = oldTayo[category]!;
        final oldCount = (oldData['count'] as int?) ?? 0;
        final diff = newCount - oldCount;
        if (diff != 0) {
          changes.add(TayoHistoryChange(category: category, change: diff));
        }
      } else {
        // 3. Brand‑new category (old count implicitly 0)
        if (newCount != 0) {
          changes.add(TayoHistoryChange(category: category, change: newCount));
        }
      }
    }

    return changes;
  }
}
