import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/Custom_form_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
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

class RegisterNewChurchScreen extends StatefulWidget {
  const RegisterNewChurchScreen({super.key});

  @override
  State<RegisterNewChurchScreen> createState() =>
      _RegisterNewChurchScreenState();
}

class _RegisterNewChurchScreenState extends State<RegisterNewChurchScreen> {
  final List<String> items = ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'];
  final List<String> roles = ['خادم', 'مخدوم'];
  DateTime? pickedDate;

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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainButton(
              title: "تسجيل كنيسة جديدة",
              onPressed: () {
                if (cubit.formkey.currentState!.validate()) {
                  if (cubit.selectedRole != null) {
                    LocalHelper.setUserType("أمين خدمة التربية الكنسية");
                  }
                  cubit.registerNewChurch();

                  log(
                    'RegisterScreen role after saving: ${LocalHelper.getUserType()}',
                  );
                }
              },
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
    log('AuthState changed: $state');

    if (state is AuthSuccessState) {
      log(
        'Registration successful, navigating to main screen with role: ${LocalHelper.getUserType()}',
      );
      pop(context);
      LocalHelper.setIsNewUser(false);
      pushToBase(context, Routes.mainScreen, extra: "خادم");
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
                  CustomButton(),
                  Gap(10),
                  Row(
                    children: [
                      Text(
                        'مرحبا! سجل كنيسة جديدة',

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
                    label: "اسم أمين خدمة التربية الكنسية",

                    icon: Icons.person_rounded,
                    child: CustomTextField(
                      controller: cubit.usernameController,
                      hintText: "اسم أمين خدمة التربية الكنسية",

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء ادخال اسم أمين خدمة التربية الكنسية';
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
                  CustomFormField(
                    label: 'اسم الكنيسة',
                    icon: Icons.church_rounded,
                    child: CustomTextField(
                      controller: cubit.churchNameController,
                      hintText: "مثال: الكاتدرائية المرقسية بالعباسية, القاهرة",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء ادخال اسم الكنيسة';
                        }
                        return null;
                      },
                    ),
                  ),

                  Gap(15),
                  CustomFormField(
                    label: 'أنشئ الكلمة السرية للخدام',
                    infoHoverText:
                        "كلمة مرور خاصة بالخدام تُستخدم للتحقق من صلاحية إنشاء حساب خادم. لا تُشارك هذه الكلمة مع المخدومين حفاظًا على أمن النظام.",
                    icon: Icons.lock_rounded,
                    child: CustomTextField(
                      controller: cubit.pinController,
                      hintText: 'الكلمة السرية للخدام',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء انشاء الكلمة السرية للخدام';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
