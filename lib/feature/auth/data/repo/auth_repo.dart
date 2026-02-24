import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
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
      if (user.photoURL == '1') {
        return 'خادم';
      } else {
        return 'مخدوم';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        return 'كلمة المرور خاطئة.';
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
  }) async {
    try {
      String? role = LocalHelper.getUserType();
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = credential.user!;
      user.updateDisplayName(name);
      if (role == 'خادم') {
        user.updatePhotoURL('1');
        LocalHelper.setUserType('خادم');
      } else {
        user.updatePhotoURL('0');
        LocalHelper.setUserType('مخدوم');
      }
      LocalHelper.setUserId(user.uid);

      return role;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'كلمة المرور ضعيفة جداً.';
      } else if (e.code == 'email-already-in-use') {
        return 'الحساب موجود بالفعل لهذا البريد الإلكتروني.';
      } else {
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
