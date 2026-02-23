import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

class AddEditNewStudentScreen extends StatefulWidget {
  const AddEditNewStudentScreen({super.key, this.student});
  final StudentModel? student;

  @override
  State<AddEditNewStudentScreen> createState() =>
      _AddEditNewStudentScreenState();
}

class _AddEditNewStudentScreenState extends State<AddEditNewStudentScreen> {
  DateTime? pickedDate;
  @override
  void initState() {
    context.read<HomeCubit>().loadStudentControllers(widget.student);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: MainButton(
            title: 'حفظ',
            onPressed: () async {
              if (cubit.formkey.currentState?.validate() ?? false) {
                if (cubit.formkey.currentState!.validate()) {
                  if (widget.student != null) {
                    cubit.updateStudent(
                      widget.student!.copyWith(
                        name: cubit.nameController.text,
                        fatherPhone: cubit.fatherPhoneController.text,
                        motherPhone: cubit.motherPhoneController.text,
                        personalPhone: cubit.personalPhoneController.text,
                        housePhone: cubit.housePhoneController.text,
                        address: cubit.addressController.text,
                        studyLevel: cubit.studyLevelController.text,
                        birthday: pickedDate,
                      ),
                    );
                    return;
                  }
                  cubit.createStudent(
                    StudentModel(
                      name: cubit.nameController.text,
                      fatherPhone: cubit.fatherPhoneController.text,
                      motherPhone: cubit.motherPhoneController.text,
                      personalPhone: cubit.personalPhoneController.text,
                      housePhone: cubit.housePhoneController.text,
                      address: cubit.addressController.text,
                      studyLevel: cubit.studyLevelController.text,
                      birthday: pickedDate,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
      body: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingState) {
            showLoadingDialog(context);
          } else if (state is HomeSuccessState) {
            pop(context);
            showMyDialoge(
              context,
              'تمت الاضافة بنجاح',
              type: DialogType.success,
            );
          } else if (state is HomeErrorState) {
            pop(context);
            showMyDialoge(context, state.message, type: DialogType.error);
          }
        },
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                24,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.whiteColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student == null
                            ? 'اضافة مخدوم جديد'
                            : 'تعديل بيانات المخدوم',
                        style: TextStyles.getSize24(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'املأ البيانات التالية',
                        style: TextStyles.getSize12(
                          color: AppColors.whiteColor.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────────
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Form(
                    key: cubit.formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormField(
                          label: 'اسم المخدوم',
                          icon: Icons.person_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل اسم المخدوم',
                            controller: cubit.nameController,
                            validator: (p0) {
                              if (p0 == null || p0.isEmpty) {
                                return 'ارجوك ادخل اسم المخدوم';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'تليفون الأب',
                          icon: Icons.phone_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل تليفون الأب',
                            controller: cubit.fatherPhoneController,
                            isPhone: true,
                            validator: (p0) {
                              if (!AppRegex.isEgyptianPhoneValid(p0!) &&
                                  p0.isNotEmpty) {
                                return 'رجاء ادخل رقم هاتف صالحا';
                              } else if (p0.isEmpty) {
                                cubit.fatherPhoneController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'تليفون الأم',
                          icon: Icons.phone_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل تليفون الأم',
                            controller: cubit.motherPhoneController,
                            isPhone: true,
                            validator: (p0) {
                              if (!AppRegex.isEgyptianPhoneValid(p0!) &&
                                  p0.isNotEmpty) {
                                return 'رجاء ادخل رقم هاتف صالحا';
                              } else if (p0.isEmpty) {
                                cubit.motherPhoneController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'تليفون المخدوم',
                          icon: Icons.smartphone_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل تليفون المخدوم',
                            controller: cubit.personalPhoneController,
                            isPhone: true,
                            validator: (p0) {
                              if (!AppRegex.isEgyptianPhoneValid(p0!) &&
                                  p0.isNotEmpty) {
                                return 'رجاء ادخل رقم هاتف صالحا';
                              } else if (p0.isEmpty) {
                                cubit.personalPhoneController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'تليفون المنزل',
                          icon: Icons.home_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل تليفون المنزل',
                            controller: cubit.housePhoneController,
                            isLandline: true,
                            validator: (p0) {
                              if (!AppRegex.isEgyptianLandlineValid(p0!) &&
                                  p0.isNotEmpty) {
                                return 'رجاء ادخل رقم هاتف صالحا';
                              } else if (p0.isEmpty) {
                                cubit.housePhoneController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'العنوان',
                          icon: Icons.location_on_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل العنوان',
                            controller: cubit.addressController,
                            validator: (p0) {
                              if (p0 == null || p0.isEmpty) {
                                cubit.addressController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'المستوى الدراسي',
                          icon: Icons.school_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل المستوى الدراسي',
                            controller: cubit.studyLevelController,
                            validator: (p0) {
                              if (p0 == null || p0.isEmpty) {
                                return 'ارجوك ادخل المستوى الدراسي';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
                        _FormField(
                          label: 'تاريخ الميلاد',
                          icon: Icons.cake_rounded,
                          child: CustomTextField(
                            controller: cubit.birthdayController,
                            readOnly: true,
                            suffixIcon: IconButton(
                              onPressed: () async {
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
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled form section with an icon and a content slot
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 16),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyles.getSize18(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Gap(8),
        child,
      ],
    );
  }
}
