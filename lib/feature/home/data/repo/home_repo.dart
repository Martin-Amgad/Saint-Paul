import 'dart:developer';

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

  //   static Future<BookListRsponse?> getNewArrivals() async {
  //     try {
  //       var res = await DioProvider.get(endpoint: ApiEndpoints.new_arrivals);

  //       if (res.statusCode == 200) {
  //         return BookListRsponse.fromJson(res.data);
  //       } else {
  //         return null;
  //       }
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       return null;
  //     }
  //   }

  //   static Future<BookListRsponse?> getAllBooks([int pageIndex = 1]) async {
  //     try {
  //       var res = await DioProvider.get(
  //         endpoint: ApiEndpoints.all_products,
  //         queryParameters: {'page': pageIndex},
  //       );

  //       if (res.statusCode == 200) {
  //         return BookListRsponse.fromJson(res.data);
  //       } else {
  //         return null;
  //       }
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       return null;
  //     }
  //   }

  //   static Future<SliderResponse?> getSlider() async {
  //     try {
  //       var res = await DioProvider.get(endpoint: ApiEndpoints.slider);

  //       if (res.statusCode == 200) {
  //         return SliderResponse.fromJson(res.data);
  //       } else {
  //         return null;
  //       }
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       return null;
  //     }
  //   }
}
