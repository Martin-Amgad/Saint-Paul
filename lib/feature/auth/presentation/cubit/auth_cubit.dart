import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/Notifications/data/fcm_token_manager.dart';
import 'package:saint_paul/feature/Notifications/data/fcm_token_repo.dart';
import 'package:saint_paul/feature/auth/data/repo/auth_repo.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());

  var formkey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordConfirmationController = TextEditingController();
  var pinController = TextEditingController();
  var birthdayController = TextEditingController();
  var churchNameController = TextEditingController();
  String? selectedYear;
  String? selectedFamily;
  String? selectedRole;
  String? selectedChurch;

  Map<String, dynamic> churches = {};

  String? adminPin = '1234';

  StreamSubscription<String>? tokenRefreshSubscription;
  bool isTokenRefreshListenerActive = false;

  /// Saves the FCM token for the currently logged‑in user
  /// and starts the token refresh listener (once).
  Future<void> saveFcmTokenAfterAuth() async {
    try {
      final uid = LocalHelper.getUserId()!;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FCMTokenRepo.saveToken(uid, token);
      }

      if (!isTokenRefreshListenerActive) {
        tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
            .listen((newToken) async {
              await FCMTokenRepo.saveToken(uid, newToken);
            });
        isTokenRefreshListenerActive = true;
      }
    } catch (e) {
      log('FCM token error: $e');
      // never fail login/register because of token issues
    }
  }

  Future<void> login() async {
    emit(AuthloadingState());
    String? response = await AuthRepo.login(
      email: emailController.text,
      password: passwordController.text,
    );
    log('Attempting to log in with email: ${emailController.text}');
    log('Attempting to log in with password: ${passwordController.text}');
    if (response == 'خادم' || response == 'مخدوم') {
      final uid = LocalHelper.getUserId()!;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FCMTokenRepo.saveToken(uid, token);
      }

      // Start listening for token refreshes
      FCMTokenManager.init(uid);

      emit(AuthSuccessState(role: response));
    } else {
      log('Login failed with response: $response');
      emit(
        AuthErrorState(
          response ?? 'حدث خطأ أثناء تسجيل الدخول. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> register() async {
    emit(AuthloadingState());
    log(
      'Selected role during registration from local: ${LocalHelper.getUserType()}',
    );

    if (pinController.text != churches[selectedChurch] &&
        LocalHelper.getUserType() == 'خادم') {
      emit(AuthErrorState('الرقم السري غير صحيح'));
      return;
    }
    log('Attempting to register with email: ${emailController.text}');
    log('Attempting to register with password: ${passwordController.text}');
    log('Attempting to register with name: ${usernameController.text}');
    log('Attempting to register with study level: $selectedYear');

    String? response = await AuthRepo.register(
      email: emailController.text,
      password: passwordController.text,
      name: usernameController.text,
      studyLevel: selectedYear,
      role: selectedRole,
      birthday: DateTime.tryParse(birthdayController.text),
      churchName: selectedChurch,
      family: selectedFamily,
    );

    if (response == 'تم إنشاء الحساب بنجاح.') {
      final uid = LocalHelper.getUserId()!;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FCMTokenRepo.saveToken(uid, token);
      }

      // Start listening for token refreshes
      FCMTokenManager.init(uid);

      emit(AuthSuccessState(role: selectedRole));
    } else {
      emit(
        AuthErrorState(
          response ?? 'حدث خطأ أثناء إنشاء الحساب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> registerNewChurch() async {
    emit(AuthloadingState());
    log(
      'Selected role during registration from local: ${LocalHelper.getUserType()}',
    );

    String? response = await AuthRepo.registerNewCHurch(
      email: emailController.text,
      password: passwordController.text,
      name: usernameController.text,
      role: "أمين خدمة التربية الكنسية",
      churchName: churchNameController.text,
      adminPin: pinController.text,
    );
    log('Attempting to register with email: ${emailController.text}');
    log('Attempting to register with password: ${passwordController.text}');
    log('Attempting to register with name: ${usernameController.text}');
    log('Attempting to register with study level: $selectedYear');
    log('response from registerNewChurch: $response');

    if (response == 'تم إنشاء الكنيسة بنجاح.') {
      emit(AuthSuccessState(role: "أمين خدمة التربية الكنسية"));
    } else {
      emit(
        AuthErrorState(
          response ?? 'حدث خطأ أثناء إنشاء الحساب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> getChurches() async {
    var response = await AuthRepo.getChurches();
    if (response != null) {
      churches = response;
      log('Fetched churches: $churches');
      emit(AuthChurchLoadedState(churches: churches));
    } else {
      emit(
        AuthErrorState(
          ' حدث خطأ أثناء إرسال بريد استعادة كلمة المرور. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    emit(AuthloadingState());

    var response = await AuthRepo.resetPassword(email);
    if (response != null) {
      emit(AuthResetPasswordSuccessState(response));
    } else {
      emit(
        AuthErrorState(
          ' حدث خطأ أثناء إرسال بريد استعادة كلمة المرور. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  //   check_forget_password() async {
  //     emit(AuthloadingState());

  //     var params = AuthParams(
  //       email: LocalHelper.getString(LocalHelper.KEmail),
  //       verify_code: int.parse(otpController.text),
  //     );

  //     var response = await AuthRepo.check_forget_password(params);
  //     if (response != null) {
  //       emit(AuthSuccessState());
  //     } else {
  //       emit(AuthErrorState('forget password Failed'));
  //     }
  //   }

  //   reset_password() async {
  //     emit(AuthloadingState());
  //     log('${LocalHelper.getString(LocalHelper.Kotp)}');
  //     var params = AuthParams(
  //       verify_code: int.tryParse(LocalHelper.getString(LocalHelper.Kotp) ?? ''),
  //       new_password: passwordController.text,
  //       new_password_confirmation: passwordConfirmationController.text,
  //     );

  //     var response = await AuthRepo.reset_password(params);

  //     if (response != null) {
  //       emit(AuthSuccessState());
  //     } else {
  //       emit(AuthErrorState('Reset password Failed'));
  //     }
  //   }
}
