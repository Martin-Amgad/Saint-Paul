import 'dart:developer';
import 'dart:io';
import 'package:saint_paul/core/extentions/image_uploader.dart';
import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class ProfileRepo {
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

  static Future<String?> updateStudent(StudentModel student) async {
    try {
      await FirebaseProvider.updateStudent(student);
      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> updateStudentImage(String path) async {
    try {
      final cloudinaryUrl = await uploadImageToCloudinary(File(path));
      if (cloudinaryUrl == null) return null;
      log('Cloudinary URL: $cloudinaryUrl');
      await FirebaseProvider.updateStudentImage(
        LocalHelper.getUserId(),
        cloudinaryUrl,
      );
      log('Student image updated successfully in Firebase');
      return cloudinaryUrl; // ← return URL not Arabic string
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<String?> deleteStudent(String studentId) async {
    try {
      await FirebaseProvider.deleteStudent(studentId);

      return 'تم حذف المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء حذف المخدوم. الرجاء المحاولة مرة أخرى.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء حذف المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<List<BadgeModel>> getBadgesFor(
    String church,
    String family,
  ) async {
    final firestoreBadges = await FirebaseProvider.getBadgesFor(church, family);
    await LocalHelper.setAllBadges(
      firestoreBadges,
    ); // update cache with fresh data
    return firestoreBadges;
  }

  static Future<void> deleteTeacher(String teacherId) async {
    try {
      await FirebaseProvider.deleteTeacher(teacherId);
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('حدث خطأ أثناء حذف الخادم. الرجاء المحاولة مرة أخرى.');
    } catch (e) {
      log(e.toString());
      throw Exception('حدث خطأ أثناء حذف الخادم. الرجاء المحاولة مرة أخرى.');
    }
  }

  static Future<void> updateTeacher(TeacherModel newTeacher) async {
    try {
      log(
        'Updating teacher: ${newTeacher.name}, Family: ${newTeacher.assignedFamily}, Year: ${newTeacher.assignedStudyLevel}',
      );
      await FirebaseProvider.updateTeacher(newTeacher);
      log('Teacher ${newTeacher.uid} updated successfully.');
    } catch (e) {
      log('Failed to update teacher ${newTeacher.uid}: $e');
      throw Exception('Failed to update teacher: $e');
    }
  }

  static Future<List<StudentModel>> fetchStudentsByIds(
    List<String> studentIds,
  ) async {
    try {
      // Implementation for fetching students by IDs
      var res = await FirebaseProvider.fetchStudentsByIds(studentIds);
      return res;
    } catch (e) {
      log('Failed to fetch students: $e');
      throw Exception('Failed to fetch students: $e');
    }
  }

  static Future<void> updateTeacherStudents({
    required String teacherId,
    required List<String> assignedStudentIds,
    required List<String> addedStudentIds,
    required List<String> removedStudentIds,
  }) async {
    await FirebaseProvider.updateTeacherAndStudents(
      teacherId: teacherId,
      assignedStudentIds: assignedStudentIds,
      addedStudentIds: addedStudentIds,
      removedStudentIds: removedStudentIds,
    );
  }
}
