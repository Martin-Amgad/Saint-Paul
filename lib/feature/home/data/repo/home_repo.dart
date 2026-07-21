import 'dart:developer';
import 'dart:io';

import 'package:saint_paul/core/extentions/image_uploader.dart';
import 'package:saint_paul/core/models/badge_model.dart';
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
    String? groupID,
    int? groupPointsDelta,
  }) async {
    try {
      // 1. Compute point deltas (no zero-deltas, no removed categories)
      final deltas = TayoHistoryModel.computeTayoChanges(
        oldTayo: oldStudent.tayo!,
        newTayo: newStudent.tayo!,
        removedCategories: tayoRemovedCategories ?? [],
      );

      log(
        'Deltas: ${deltas.map((d) => '${d.category}: ${d.change}').join(', ')}',
      );

      // 2. Optional: update all students if global categories changed
      if ((tayoNewCategories?.isNotEmpty ?? false) ||
          (tayoRemovedCategories?.isNotEmpty ?? false)) {
        await FirebaseProvider.applyFamilyTayoCategoryChanges(
          tayoNewCategories,
          tayoRemovedCategories,
          excludeStudentId: newStudent.uid ?? oldStudent.uid,
        );
      }

      // 3. Get teacher info
      log('Fetching teacher data from local storage...');
      final teacher = LocalHelper.getTeacherData();
      log('Teacher data from local storage: $teacher');

      if (teacher == null || teacher.uid == null || teacher.name == null) {
        return 'تعذر الحصول على بيانات المعلم. الرجاء تسجيل الدخول مجدداً.';
      }

      log('Teacher: uid=${teacher.uid}, name=${teacher.name}');

      // 4. Atomic student update + history (the ONLY write to this student’s tayo)
      log('Updating student ${newStudent.uid} with deltas: $deltas');

      final otherFields = newStudent.toUpdateData();
      otherFields.remove('tayo');
      otherFields.remove('totalTayo');

      await FirebaseProvider.updateStudentWithHistory(
        studentId: newStudent.uid ?? oldStudent.uid!,
        deltas: deltas,
        removedCategories: tayoRemovedCategories ?? [],
        teacherId: teacher.uid!,
        teacherName: teacher.name!,
        groupID: groupID,
        groupPointsDelta: groupPointsDelta,
        otherFields: otherFields.isNotEmpty ? otherFields : null,
      );

      log('✅ Student updated successfully.');

      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      throw Exception('Failed to update student: ${e.toString()}');
    } catch (e) {
      log('Unexpected error during student update in Repo: ${e.toString()}');
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

  static Future<List<BadgeModel>> getCurrentChurchFamilyBadges() async {
    try {
      final badges = await FirebaseProvider.getChurchFamilyBadges(
        LocalHelper.getUserChurchName(),
        LocalHelper.getUserFamily(),
      );
      log('Fetched badges from Firebase: $badges');
      return badges;
    } catch (e) {
      log(e.toString());
      return []; // Return an empty list on error
    }
  }

  static Future<void> createBadge(String badgeName, String url) async {
    try {
      await FirebaseProvider.createBadgeForChurchFamily(badgeName, url);
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('Failed to update badge in Firebase: ${e.toString()}');
    }
  }

  static Future<void> addChurchToAllDocs(String churchName) async {
    try {
      log(
        'Adding church "$churchName" to all documents in the Students collection...',
      );
      await FirebaseProvider.addFieldToAllDocs(churchName);
      log('Successfully added church "$churchName" to all documents.');
    } on Exception catch (e) {
      log(
        'Failed to add church "$churchName" to all documents: ${e.toString()}',
      );
      throw Exception('Failed to add church to all documents: ${e.toString()}');
    }
  }
}
