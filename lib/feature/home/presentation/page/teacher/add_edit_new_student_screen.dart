import 'package:flutter/material.dart' hide FormField;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/components/inputs/form_field.dart';
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
  final List<String> items = ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'];

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
                        studyLevel: cubit.selectedValue,
                        birthday: pickedDate,
                        responsibleTeacher:
                            cubit.responsibleTeacherController.text,
                      ),
                    );
                    return;
                  }
                  cubit.createStudent(
                    StudentModel(
                      uid: LocalHelper.getUserId() ?? '',
                      name: cubit.nameController.text,
                      fatherPhone: cubit.fatherPhoneController.text,
                      motherPhone: cubit.motherPhoneController.text,
                      personalPhone: cubit.personalPhoneController.text,
                      housePhone: cubit.housePhoneController.text,
                      address: cubit.addressController.text,
                      studyLevel: cubit.selectedValue,
                      birthday: pickedDate,
                      responsibleTeacher:
                          cubit.responsibleTeacherController.text,
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
                  CustomBackButton(),
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
                        CustomFormField(
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
                        CustomFormField(
                          label: 'المستوى الدراسي',
                          icon: Icons.school_rounded,
                          child: DropdownButtonFormField<String>(
                            isDense: false,
                            value: cubit.selectedValue,
                            hint: Text(
                              'المستوى الدراسي',
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
                              setState(() => cubit.selectedValue = value);
                            },
                          ),
                        ),
                        const Gap(16),
                        CustomFormField(
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
                        const Gap(16),
                        CustomFormField(
                          label: ' الخادم المسئول',
                          icon: Icons.supervisor_account_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل الخادم المسئول',
                            controller: cubit.responsibleTeacherController,
                          ),
                        ),
                        const Gap(16),
                        CustomFormField(
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
                        CustomFormField(
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
                        CustomFormField(
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
                        CustomFormField(
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
                        CustomFormField(
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
