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
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
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
  final List<String> families = SchoolYearsModel.getFamilies();
  final List<String> roles = ['خادم', 'مخدوم'];
  List<String> items = SchoolYearsModel.allYears.values
      .expand((list) => list)
      .toList();

  DateTime? pickedDate;

  @override
  initState() {
    super.initState();
    log('RegisterScreen role: ${LocalHelper.getUserType()}');
    context.read<AuthCubit>().getChurches();

    log('loaded churches: ${context.read<AuthCubit>().churches}');
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<AuthCubit>();

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
                  if (cubit.selectedRole != null) {
                    LocalHelper.setUserType(cubit.selectedRole!);
                  }
                  cubit.register();

                  log(
                    'RegisterScreen role after saving: ${LocalHelper.getUserType()}',
                  );
                }
              },
            ),
            Column(
              children: [
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
          ],
        ),
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) => _blockListener(context, state),
        builder: (context, state) {
          if (state is AuthChurchLoadedState) {
            log('Churches loaded: ${state.churches}');
          }
          return _signUpBody(cubit, context);
        },
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
    } else if (state is AuthChurchLoadedState) {
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
                        'مرحبا! سجل حساب جديد',
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
                        } else if (!AppRegex.isValidEmail(value.trim())) {
                          return 'الرجاء ادخال بريد الكتروني صالح';
                        }
                        return null;
                      },
                    ),
                  ),
                  Gap(15),
                  CustomFormField(
                    label: 'الكنيسة',
                    icon: Icons.church_rounded,
                    child: DropdownButtonFormField<String>(
                      onTap: () {
                        debugPrint('Church dropdown tapped');
                      },
                      isDense: false,
                      value: cubit.selectedChurch,
                      hint: Text(
                        'الكنيسة',
                        style: TextStyles.getSize16(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                        ).copyWith(fontFamily: 'Cairo'),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                      ),
                      dropdownColor: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      style: TextStyles.getSize16(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return cubit.churches.keys.map((item) {
                          return Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          );
                        }).toList();
                      },

                      items: cubit.churches.keys.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => cubit.selectedChurch = value!);
                      },
                    ),
                  ),
                  Gap(15),
                  CustomFormField(
                    label: 'الانضمام كـ',
                    icon: Icons.church_rounded,
                    child: DropdownButtonFormField<String>(
                      isDense: false,
                      value: cubit.selectedRole,
                      hint: Text(
                        'الانضمام كـ',
                        style: TextStyles.getSize16(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                        ).copyWith(fontFamily: 'Cairo'),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                      ),
                      dropdownColor: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      style: TextStyles.getSize16(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return roles.map((item) {
                          return Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          );
                        }).toList();
                      },

                      items: roles.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cubit.selectedRole = value;
                        });
                      },
                    ),
                  ),
                  Gap(15),

                  CustomFormField(
                    label: 'الأسرة',
                    icon: Icons.group_rounded,
                    child: DropdownButtonFormField<String>(
                      isDense: false,
                      value: cubit.selectedFamily,
                      hint: Text(
                        'الأسرة',
                        style: TextStyles.getSize16(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                        ).copyWith(fontFamily: 'Cairo'),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                      ),
                      dropdownColor: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      style: TextStyles.getSize16(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return families.map((item) {
                          return Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          );
                        }).toList();
                      },

                      items: families.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cubit.selectedFamily = value;
                          items = SchoolYearsModel.allYears[value] ?? [];
                        });
                      },
                    ),
                  ),
                  Gap(15),
                  CustomFormField(
                    label: cubit.selectedRole == 'مخدوم'
                        ? " المستوى الدراسي"
                        : "السنة المسئول عنها",
                    icon: Icons.school_rounded,
                    child: DropdownButtonFormField<String>(
                      isDense: false,
                      value: cubit.selectedYear,
                      hint: Text(
                        cubit.selectedRole == 'مخدوم'
                            ? " المستوى الدراسي"
                            : "السنة المسئول عنها",
                        style: TextStyles.getSize16(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                        ).copyWith(fontFamily: 'Cairo'),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                      ),
                      dropdownColor: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      style: TextStyles.getSize16(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return items.map((item) {
                          return Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          );
                        }).toList();
                      },

                      items: items.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => cubit.selectedYear = value);
                      },
                    ),
                  ),
                  if (cubit.selectedRole == 'مخدوم') ...[
                    const Gap(16),
                    CustomFormField(
                      label: 'تاريخ الميلاد',
                      icon: Icons.cake_rounded,
                      child: CustomTextField(
                        controller: cubit.birthdayController,
                        readOnly: true,
                        hintText: 'تاريخ الميلاد',
                        onTap: () async {
                          var selectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365 * 100),
                            ),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            pickedDate = selectedDate;
                            cubit.birthdayController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);
                          }
                        },
                        suffixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primaryColor,
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال تاريخ الميلاد';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                  if (cubit.selectedRole == 'خادم') ...[
                    Gap(15),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
