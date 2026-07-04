import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class AuthRepo {
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      LocalHelper.setUserId(user.uid);

      // Load role‑specific data from Firestore
      if (user.photoURL == '0') {
        // Student
        final snapshot = await FirebaseProvider.getStudentByID(user.uid);
        final userData = StudentModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        LocalHelper.setUserData(userData.toJsonLocal());
        LocalHelper.setUserGroup('${userData.groupID}');
        LocalHelper.setUserType('مخدوم');
      } else if (user.photoURL == '1') {
        // Teacher
        final snapshot = await FirebaseProvider.getTeacherByID(user.uid);
        final userData = TeacherModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        LocalHelper.setUserData(userData.toJsonLocal());
        LocalHelper.setUserType('خادم');
      } else {
        // Fallback (should not normally happen)
        LocalHelper.setUserType('مخدوم');
      }

      log('User logged in with email: $email');
      log('User UID: ${user.uid}');
      log('Role indicator (photoURL): ${user.photoURL}');
      log('================================');

      return user.photoURL == '1' ? 'خادم' : 'مخدوم';
    } on FirebaseAuthException catch (e) {
      log('Login error code: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
        case 'wrong-password':
          return 'كلمة المرور خاطئة.';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح.';
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'invalid-credential':
          return 'بيانات تسجيل الدخول غير صحيحة.';
        default:
          return 'حدث خطأ أثناء تسجيل الدخول. الرجاء المحاولة مرة أخرى.';
      }
    } catch (e) {
      log('Login error: $e');
      return 'حدث خطأ أثناء تسجيل الدخول. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?> register({
    required String email,
    required String password,
    required String name,
    String? studyLevel,
    String? role,
    DateTime? birthday,
    String? church,
  }) async {
    try {
      final tayo = await FirebaseProvider.getDefaultTayo();

      if (tayo.isEmpty) {
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user!;

      try {
        if (role == 'مخدوم') {
          await FirebaseProvider.createStudent(
            StudentModel(
              uid: user.uid,
              name: name,
              studyLevel: studyLevel,
              birthday: birthday,
              tayo: tayo,
            ),
          );
        } else if (role == 'خادم') {
          await FirebaseProvider.createTeacher(
            TeacherModel(
              uid: user.uid,
              name: name,
              church: church,
              // adminPin if you have one
            ),
          );
        }
      } catch (_) {
        // Roll back Firebase Auth account if Firestore write fails
        await user.delete();
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }

      await user.updateDisplayName(name);

      if (role == 'خادم') {
        await user.updatePhotoURL('1');
        LocalHelper.setUserType('خادم');
      } else {
        await user.updatePhotoURL('0');
        LocalHelper.setUserType('مخدوم');
      }

      log('User logged in with email: $email');
      log('User UID: ${user.uid}');
      log('================================');

      LocalHelper.setUserId(user.uid);

      if (role == 'خادم') {
        LocalHelper.setUserData(
          TeacherModel(uid: user.uid, name: name, church: church).toJsonLocal(),
        );
      } else {
        LocalHelper.setUserData(
          StudentModel(
            uid: user.uid,
            name: name,
            studyLevel: studyLevel,
            birthday: birthday,
            tayo: tayo,
          ).toJsonLocal(),
        );
      }

      return 'تم إنشاء الحساب بنجاح.';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً.';
        case 'email-already-in-use':
          return 'الحساب موجود بالفعل لهذا البريد الإلكتروني.';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح.';
        case 'operation-not-allowed':
          return 'تسجيل الحساب غير مسموح به حالياً.';
        default:
          log('Register error code: ${e.code}');
          return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }
    } catch (e) {
      log('Register error: $e');
      return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<String?>? resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      return null;
    }
  }

  //   static Future<AuthResponse?> check_forget_password(AuthParams params) async {
  //     try {
  //       var res = await DioProvider.post(
  //         endpoint: ApiEndpoints.check_forget_password,
  //         data: params.toJson(),
  //       );

  //       if (res.statusCode == 200) {
  //         return AuthResponse.fromJson(res.data);
  //       } else {
  //         return null;
  //       }
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       return null;
  //     }
  //   }

  //   static Future<AuthResponse?> reset_password(AuthParams params) async {
  //     try {
  //       var res = await DioProvider.post(
  //         endpoint: ApiEndpoints.reset_password,
  //         data: params.toJson(),
  //       );

  //       if (res.statusCode == 200) {
  //         return AuthResponse.fromJson(res.data);
  //       } else {
  //         return null;
  //       }
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       return null;
  //     }
  //   }
}
