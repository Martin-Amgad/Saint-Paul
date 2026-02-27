import 'dart:developer';
import 'dart:io';
import 'package:saint_paul/core/extentions/image_uploader.dart';
import 'package:saint_paul/core/models/student_model.dart';
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
}
