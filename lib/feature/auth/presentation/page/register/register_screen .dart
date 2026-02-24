import 'dart:developer';

import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/form_field.dart';
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
      bottomNavigationBar: Padding(
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
                    style: TextStyles.getSize16(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) => _blockListener(context, state),
        child: _signUpBody(cubit, context),
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

  Form _signUpBody(AuthCubit cubit, BuildContext context) {
    return Form(
      key: cubit.formkey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),

              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(10),
                  CustomBackButton(),
                  Gap(10),
                  Row(
                    children: [
                      Text(
                        'مرحبا! سجل حساب جديد\n گ "${LocalHelper.getUserType()}"',
                        style: TextStyles.getSize24(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(5),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CustomFormField(
                    label: 'اسم المستخدم',
                    icon: Icons.person_rounded,
                    child: CustomTextField(
                      controller: cubit.usernameController,
                      hintText: 'اسم المستخدم',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء ادخال اسم المستخدم';
                        }
                        return null;
                      },
                    ),
                  ),
                  Gap(15),
                  CustomFormField(
                    label: 'البريد الالكتروني',
                    icon: Icons.email_rounded,
                    child: CustomTextField(
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
                  ),
                  Gap(15),
                  CustomFormField(
                    label: 'كلمة المرور',
                    icon: Icons.lock_rounded,
                    child: CustomTextField(
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
                  ),

                  Gap(15),
                  CustomFormField(
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_rounded,
                    child: CustomTextField(
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
                  ),
                  Gap(15),
                  if (LocalHelper.getUserType() == 'خادم') ...[
                    CustomFormField(
                      label: 'الكلمة السرية للخادم',
                      icon: Icons.lock_rounded,
                      child: CustomTextField(
                        controller: cubit.pinController,
                        hintText: 'الكلمة السرية للخادم',
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال الكلمة السرية للخادم';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
