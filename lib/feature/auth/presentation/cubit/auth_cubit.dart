import 'dart:developer';

import 'package:bloc/bloc.dart';
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
    if (pinController.text != adminPin && LocalHelper.getUserType() == 'خادم') {
      emit(AuthErrorState('الرقم السري غير صحيح'));
      return;
    }
    String? response = await AuthRepo.register(
      email: emailController.text,
      password: passwordController.text,
      name: usernameController.text,
    );
    log('Attempting to register with email: ${emailController.text}');
    log('Attempting to register with password: ${passwordController.text}');
    if (response == 'خادم' || response == 'مخدوم') {
      emit(AuthSuccessState(role: response));
    } else {
      emit(
        AuthErrorState(
          response ?? 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  //   forget_password() async {
  //     emit(AuthloadingState());

  //     var params = AuthParams(
  //       email: LocalHelper.getString(LocalHelper.KEmail) ?? emailController.text,
  //     );
  //     var response = await AuthRepo.forget_password(params);
  //     if (response != null) {
  //       emit(AuthSuccessState());
  //     } else {
  //       emit(AuthErrorState('forget password Failed'));
  //     }
  //   }

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
