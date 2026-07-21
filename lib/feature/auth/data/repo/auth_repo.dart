import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saint_paul/core/models/church_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/Notifications/data/fcm_token_manager.dart';
import 'package:saint_paul/feature/Notifications/data/fcm_token_repo.dart';

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
      log(
        'User logged in: ${user.email}, UID: ${user.uid}, Role indicator (photoURL): ${user.photoURL}',
      );

      // Load role‑specific data from Firestore
      if (user.photoURL == '0') {
        // Student
        final snapshot = await FirebaseProvider.getStudentByID(user.uid);
        final userData = StudentModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        LocalHelper.setStudentData(userData.toJsonLocal());
        LocalHelper.setUserGroup('${userData.groupID}');
        LocalHelper.setUserType('مخدوم');
        await LocalHelper.setUserFamily(userData.family ?? '');
        await LocalHelper.setUserStudyLevel(userData.studyLevel ?? '');
        await LocalHelper.setUserChurchName(userData.church ?? '');
      } else if (user.photoURL == '1') {
        // Teacher
        final userData = await FirebaseProvider.getTeacherByID(user.uid);

        LocalHelper.setUserType('خادم');
        LocalHelper.setTeacherName(userData?.name ?? '');
        await LocalHelper.setUserFamily(userData?.assignedFamily ?? '');
        await LocalHelper.setUserStudyLevel(userData?.assignedStudyLevel ?? '');
        await LocalHelper.setUserChurchName(userData?.church ?? '');
        LocalHelper.setTeacherData(
          userData ??
              TeacherModel(
                uid: user.uid,
                name: '',
                church: '',
                role: '',
                assignedFamily: '',
                assignedStudyLevel: '',
              ),
        );
      } else if (user.photoURL == '2') {
        // Church Admin
        final userData = await FirebaseProvider.getTeacherByID(user.uid);

        LocalHelper.setUserType('أمين خدمة التربية الكنسية');
        LocalHelper.setTeacherName(userData?.name ?? '');
        await LocalHelper.setUserChurchName(userData?.church ?? '');
        LocalHelper.setTeacherData(
          userData ??
              TeacherModel(
                uid: user.uid,
                name: '',
                church: '',
                role: '',
                assignedFamily: '',
                assignedStudyLevel: '',
              ),
        );
      }

      log('User logged in with email: $email');
      log('User UID: ${user.uid}');
      log('Role indicator (photoURL): ${user.photoURL}');
      log('================================');

      return user.photoURL == '1' || user.photoURL == '2' ? 'خادم' : 'مخدوم';
    } on FirebaseAuthException catch (e) {
      log('Login error code: ${e.code}');
      log('Login error message: ${e.message}');
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
    String? family,
    String? role,
    DateTime? birthday,
    String? churchName,
  }) async {
    try {
      log('Starting registration in Repo ');
      final tayo = await FirebaseProvider.getChurchDefaultFamilyTayo(
        family ?? '',
      );

      // 1. Create Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;

      // 2. Prepare role‑specific data (only once)
      final isTeacher = (role == 'خادم');
      final photoURL = isTeacher ? '1' : '0';
      final userType = isTeacher ? 'خادم' : 'مخدوم';

      // 3. Create Firestore document
      try {
        if (!isTeacher) {
          await FirebaseProvider.createStudent(
            StudentModel(
              uid: user.uid,
              name: name,
              studyLevel: studyLevel,
              birthday: birthday,
              tayo: tayo,
              church: churchName,
              family: family,
            ),
          );
        } else if (isTeacher) {
          await FirebaseProvider.createTeacher(
            TeacherModel(
              uid: user.uid,
              name: name,
              church: churchName,
              assignedFamily: family,
              role: role,
              assignedStudyLevel: studyLevel,
              // adminPin if you have one
            ),
          );
        }
      } catch (_) {
        // Roll back Firebase Auth account if Firestore write fails
        await user.delete();
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }

      // 4. Update Auth profile metadata
      await user.updateDisplayName(name);
      await user.updatePhotoURL(photoURL);

      // 5. Save everything to local storage (using the correct methods)
      LocalHelper.setUserId(user.uid);
      LocalHelper.setUserType(userType);
      await LocalHelper.setUserFamily(family ?? '');
      await LocalHelper.setUserStudyLevel(studyLevel ?? '');
      await LocalHelper.setUserChurchName(churchName ?? '');

      if (isTeacher) {
        LocalHelper.setTeacherName(name);
        await LocalHelper.setTeacherData(
          TeacherModel(
            uid: user.uid,
            name: name,
            role: role,
            church: churchName,
            assignedFamily: family,
            assignedStudyLevel: studyLevel,
          ),
        );
        // await LocalHelper.setUserStudyLevel(studyLevel ?? '');
      } else {
        await LocalHelper.setStudentData(
          StudentModel(
            uid: user.uid,
            name: name,
            studyLevel: studyLevel,
            birthday: birthday,
            tayo: tayo,
            church: churchName,
            family: family,
          ).toJsonLocal(),
        );
      }

      log('User registered: $email, role: $role');
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

  static Future<String> registerNewCHurch({
    required String email,
    required String password,
    required String name,
    String? role,
    required String churchName,
    String? adminPin,
  }) async {
    try {
      // 1. Create Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;

      // 2. Create Firestore document
      try {
        await FirebaseProvider.createTeacher(
          TeacherModel(
            uid: user.uid,
            name: name,
            church: churchName,
            role: "أمين خدمة التربية الكنسية",
            // adminPin if you have one
          ),
        );

        await FirebaseProvider.updateDefaultsChurchName(churchName, adminPin);
        await FirebaseProvider.createChurch(
          ChurchModel(
            adminPin: adminPin,
            churchName: churchName,
            points: {},
            tayo: {},
          ),
        );
      } catch (_) {
        // Roll back Firebase Auth account if Firestore write fails
        await user.delete();
        return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.';
      }

      // 3. Update Auth profile metadata
      await user.updateDisplayName(name);
      await user.updatePhotoURL(
        "2",
      ); // Use "2" to indicate a new church registration

      // 4. Save everything to local storage (using the correct methods)
      LocalHelper.setUserId(user.uid);
      LocalHelper.setUserType("أمين خدمة التربية الكنسية");
      LocalHelper.setUserChurchName(churchName);

      LocalHelper.setTeacherName(name);
      await LocalHelper.setTeacherData(
        TeacherModel(
          uid: user.uid,
          name: name,
          church: churchName,
          role: "أمين خدمة التربية الكنسية",
        ),
      );

      log('User registered: $email, role: $role');
      return 'تم إنشاء الكنيسة بنجاح.';
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

  static Future<Map<String, dynamic>?>? getChurches() async {
    try {
      final churches = await FirebaseProvider.getChurches();
      log('Fetched churches in Repo: $churches');

      return churches;
    } catch (e) {
      log('Error fetching churches: $e');
      return null;
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

  static Future<void> logout() async {
    // 1. Delete FCM token from Firestore
    await FCMTokenRepo.deleteToken();

    // 2. Cancel the token refresh listener
    FCMTokenManager.dispose();

    // 3. Sign out from Firebase Auth
    await FirebaseAuth.instance.signOut();

    // 4. Clear local session data (your existing logic)
    LocalHelper.setIsNewUser(true);
    LocalHelper.setUserType('null??????');
    // add any other cleanup you need
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

