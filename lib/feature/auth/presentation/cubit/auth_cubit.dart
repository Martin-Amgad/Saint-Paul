import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
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
  String? selectedValue;
  String? selectedRole;

  String? adminPin = '1234';

  Future<void> login() async {
    emit(AuthloadingState());
    String? response = await AuthRepo.login(
      email: emailController.text,
      password: passwordController.text,
    );
    log('Attempting to log in with email: ${emailController.text}');
    log('Attempting to log in with password: ${passwordController.text}');
    if (response == 'خادم' || response == 'مخدوم') {
      emit(AuthSuccessState(role: response));
    } else {
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

    var snapshot = await FirebaseProvider.getTeacherByID(
      '28W6AI0V3SGxJI7qHY73',
    );
    var teacherData = snapshot.data() as Map<String, dynamic>;
    adminPin = teacherData['adminPin'] as String?;
    if (pinController.text != adminPin && LocalHelper.getUserType() == 'خادم') {
      emit(AuthErrorState('الرقم السري غير صحيح'));
      return;
    }
    String? response = await AuthRepo.register(
      email: emailController.text,
      password: passwordController.text,
      name: usernameController.text,
      studyLevel: selectedValue,
      role: selectedRole,
      birthday: DateTime.tryParse(birthdayController.text),
    );
    log('Attempting to register with email: ${emailController.text}');
    log('Attempting to register with password: ${passwordController.text}');
    log('Attempting to register with name: ${usernameController.text}');
    log('Attempting to register with study level: $selectedValue');

    if (response == 'تم إنشاء الحساب بنجاح.') {
      emit(AuthSuccessState(role: selectedRole));
    } else {
      emit(
        AuthErrorState(
          response ?? 'حدث خطأ أثناء إنشاء الحساب. الرجاء المحاولة مرة أخرى.',
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
