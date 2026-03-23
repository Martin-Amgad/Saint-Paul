import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class AuthRepo {
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;

      LocalHelper.setUserId(user.uid);

      if (user.photoURL == '0') {
        var snapshot = await FirebaseProvider.getStudentByID(
          credential.user!.uid,
        );
        var userData = StudentModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        LocalHelper.setUserData(userData.toJsonLocal());
        LocalHelper.setUserGroup('${userData.groupID}');

        log('User data loaded from Firebase: ${userData.toJsonLocal()}');
      }
      log('User logged in with email: $email');
      log('User UID: ${user.uid}');
      log('LocalHelper User UID: ${LocalHelper.getUserId()}');
      log('User display name: ${user.displayName}');
      log('User photo URL (role indicator): ${user.photoURL}');

      log('================================');
      if (user.photoURL == '1') {
        LocalHelper.setUserType('خادم');
        return 'خادم';
      } else {
        LocalHelper.setUserType('مخدوم');
        return 'مخدوم';
      }
    } on FirebaseAuthException catch (e) {
      log('Login error code: ${e.code}');
      if (e.code == 'user-not-found') {
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        return 'كلمة المرور خاطئة.';
      } else if (e.code == 'invalid-email') {
        return 'البريد الإلكتروني غير صالح.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        return 'بيانات تسجيل الدخول غير صحيحة.';
      } else if (e.code == 'invalid-credential') {
        return 'بيانات  تسجيل الدخول غير صحيحة.';
      } else {
        return 'حدث خطأ أثناء تسجيل الدخول. الرجاء المحاولة مرة أخرى.';
      }
    } catch (e) {
      log('Login error: ${e.toString()}');
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
  }) async {
    try {
      var tayo = await FirebaseProvider.getDefaultTayo();
      if (tayo.isEmpty) {
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = credential.user!;

      if (role == 'مخدوم') {
        try {
          await FirebaseProvider.createStudent(
            StudentModel(
              uid: user.uid,
              name: name,
              studyLevel: studyLevel,
              birthday: birthday,
              tayo: tayo,
            ),
          );
        } on Exception catch (_) {
          await user.delete();
          return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
        }
      }
      log('User logged in with email: $email');
      log('User UID: ${user.uid}');
      log('LocalHelper User UID: ${LocalHelper.getUserId()}');
      log('User display name: ${user.displayName}');
      log('User photo URL (role indicator): ${user.photoURL}');
      user.updateDisplayName(name);
      if (role == 'خادم') {
        user.updatePhotoURL('1');
        LocalHelper.setUserType('خادم');
      } else {
        user.updatePhotoURL('0');
        LocalHelper.setUserType('مخدوم');
      }
      log('================================');
      LocalHelper.setUserId(user.uid);
      log('LocalHelper User UID: ${LocalHelper.getUserId()}');

      LocalHelper.setUserData(
        StudentModel(
          uid: user.uid,
          name: name,
          studyLevel: studyLevel,
          birthday: birthday,
          tayo: tayo,
        ).toJsonLocal(),
      );

      return 'تم إنشاء الحساب بنجاح.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'كلمة المرور ضعيفة جداً.';
      } else if (e.code == 'email-already-in-use') {
        return 'الحساب موجود بالفعل لهذا البريد الإلكتروني.';
      } else if (e.code == 'invalid-email') {
        return 'البريد الإلكتروني غير صالح.';
      } else if (e.code == 'operation-not-allowed') {
        return 'تسجيل الحساب غير مسموح به حالياً.';
      } else {
        log('Register error code: ${e.code}');
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }
    } catch (e) {
      log('Register error: ${e.toString()}');
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
