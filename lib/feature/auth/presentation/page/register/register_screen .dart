import 'dart:developer';

import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  initState() {
    super.initState();
    log('RegisterScreen role: ${LocalHelper.getUserType()}');
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<AuthCubit>();

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainButton(
                title: 'تسجيل حساب جديد',
                onPressed: () {
                  if (cubit.formkey.currentState!.validate()) {
                    cubit.register();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('هل لديك حساب؟', style: TextStyles.getSize16()),
                  TextButton(
                    onPressed: () {
                      pushWithReplacement(context, Routes.login);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      ' تسجيل الدخول الآن',
                      style: TextStyles.getSize16(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            pop(context);
          },
          child: Image.asset(AppAssets.arrowBack, width: 41, height: 41),
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) => _blockListener(context, state),
          child: _signUpBody(cubit, context),
        ),
      ),
    );
  }

  void _blockListener(BuildContext context, AuthState state) {
    if (state is AuthSuccessState) {
      log(
        'Registration successful, navigating to main screen with role: ${LocalHelper.getUserType()}',
      );
      pop(context);
      LocalHelper.setIsNewUser(false);
      pushToBase(context, Routes.mainScreen, extra: LocalHelper.getUserType());
    } else if (state is AuthErrorState) {
      pop(context);
      showMyDialoge(context, state.error);
    } else {
      showLoadingDialog(context);
    }
  }

  Padding _signUpBody(AuthCubit cubit, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: cubit.formkey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبا! سجل حساب جديد\n گ "${LocalHelper.getUserType()}"',
                style: TextStyles.getSize24(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(40),
              CustomTextField(
                controller: cubit.usernameController,
                hintText: 'اسم المستخدم',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              Gap(15),
              CustomTextField(
                controller: cubit.emailController,
                hintText: '   البريد الالكتروني',
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
                hintText: 'كلمة المرور',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال كلمة المرور';
                  } else if (value !=
                      cubit.passwordConfirmationController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              Gap(15),
              CustomTextField(
                controller: cubit.passwordConfirmationController,
                hintText: 'تأكيد كلمة المرور',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال تأكيد كلمة المرور';
                  } else if (value != cubit.passwordController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              Gap(15),
              if (LocalHelper.getUserType() == 'خادم') ...[
                CustomTextField(
                  controller: cubit.pinController,
                  hintText: 'الكلمه السرية للخادم',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال الكلمه السرية للخادم';
                    }
                    return null;
                  },
                ),
                Gap(30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
