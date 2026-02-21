import 'dart:developer';

import 'package:saint_paul/components/app_bar/app_bar_with_back.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  initState() {
    super.initState();
    log('LoginScreen role: ${LocalHelper.getUserType()}');
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<AuthCubit>();

    return Scaffold(
      bottomNavigationBar: _goToSignUp(cubit, context),
      appBar: AppBarWithBack(),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) => _blockListener(context, state),
          child: _loginBody(cubit, context),
        ),
      ),
    );
  }

  SafeArea _goToSignUp(AuthCubit cubit, BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainButton(
              title: 'تسجيل الدخول',
              onPressed: () {
                if (cubit.formkey.currentState!.validate()) {
                  cubit.login();
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ليس لديك حساب؟', style: TextStyles.getSize16()),
                TextButton(
                  onPressed: () {
                    pushWithReplacement(context, Routes.register);
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    ' انشاء حساب',
                    style: TextStyles.getSize16(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding _loginBody(AuthCubit cubit, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: cubit.formkey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('سررنا برؤيتك من جديد!', style: TextStyles.getSize30()),
              Gap(50),
              CustomTextField(
                controller: cubit.emailController,
                hintText: 'ادخل البريد الالكتروني',
                isEmail: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال البريد الالكتروني';
                  }
                  return null;
                },
              ),
              Gap(15),
              CustomTextField(
                controller: cubit.passwordController,
                hintText: 'ادخل كلمة المرور',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال كلمة المرور';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      //pushTo(context, Routes.emailScreen);
                    },
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyles.getSize16(),
                    ),
                  ),
                ],
              ),
              Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}

void _blockListener(BuildContext context, AuthState state) {
  if (state is AuthSuccessState) {
    pop(context);
    LocalHelper.setIsNewUser(false);
    pushToBase(context, Routes.mainScreen, extra: LocalHelper.getUserType());
  } else if (state is AuthErrorState) {
    pop(context);
    showMyDialoge(context, state.error, type: DialogType.error);
  } else {
    showLoadingDialog(context);
  }
}
