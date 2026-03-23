import 'dart:developer';

import 'package:flutter/material.dart' hide FormField;
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/inputs/form_field.dart';

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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) => _blockListener(context, state),
        child: _loginBody(cubit, context),
      ),
    );
  }

  Padding _goToSignUp(AuthCubit cubit, BuildContext context) {
    return Padding(
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
    );
  }

  Form _loginBody(AuthCubit cubit, BuildContext context) {
    return Form(
      key: cubit.formkey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
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
                            'سررنا برؤيتك من جديد!',
                            style: TextStyles.getSize30(
                              fontSize: 32,
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(5),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CustomFormField(
                        label: 'البريد الالكتروني',
                        icon: Icons.email_outlined,
                        child: CustomTextField(
                          controller: cubit.emailController,
                          hintText: 'ادخل البريد الالكتروني',
                          isEmail: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء ادخال البريد الالكتروني';
                            } else if (!AppRegex.isValidEmail(value.trim())) {
                              return 'الرجاء ادخال بريد الكتروني صالح';
                            }
                            return null;
                          },
                        ),
                      ),

                      Gap(15),
                      CustomFormField(
                        label: 'كلمة المرور',
                        icon: Icons.lock_outline,
                        child: CustomTextField(
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (cubit.emailController.text.isEmpty) {
                                showMyDialoge(
                                  context,
                                  'الرجاء ادخال البريد الالكتروني لاستعادة كلمة المرور',
                                  type: DialogType.error,
                                );
                                return;
                              } else if (!AppRegex.isValidEmail(
                                cubit.emailController.text,
                              )) {
                                showMyDialoge(
                                  context,
                                  'الرجاء ادخال بريد الكتروني صالح لاستعادة كلمة المرور',
                                  type: DialogType.error,
                                );
                                return;
                              }
                              cubit.sendResetPasswordEmail(
                                cubit.emailController.text,
                              );
                            },
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyles.getSize16(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _blockListener(BuildContext context, AuthState state) {
  if (state is AuthSuccessState) {
    pop(context);
    LocalHelper.setIsNewUser(false);
    pushToBase(context, Routes.mainScreen, extra: state.role);
  } else if (state is AuthResetPasswordSuccessState) {
    pop(context);
    showMyDialoge(context, state.message, type: DialogType.success);
  } else if (state is AuthErrorState) {
    pop(context);
    showMyDialoge(context, state.error, type: DialogType.error);
  } else {
    showLoadingDialog(context);
  }
}
