import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide FormField;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/Custom_form_field.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
import 'package:saint_paul/feature/home/widgets/student_info_edit_builder.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';
import 'package:saint_paul/feature/profile/widgets/student_card.dart';

class EditTeachersInfoScreen extends StatefulWidget {
  const EditTeachersInfoScreen({super.key, this.teacher});
  final TeacherModel? teacher;

  @override
  State<EditTeachersInfoScreen> createState() => _EditTeachersInfoScreenState();
}

class _EditTeachersInfoScreenState extends State<EditTeachersInfoScreen> {
  List<String> familySelection = [];
  List<String> assignedStudyYearSelection = [];
  List<String> roleSelection = [
    'خادم',
    'أمين الخدمة',
    'أمين خدمة التربية الكنسية',
  ];
  List<String>? updatedIds = [];

  @override
  void initState() {
    super.initState();
    // Load teacher data into controllers if editing
    final cubit = context.read<ProfileCubit>();
    updatedIds = List.from(widget.teacher?.assignedStudentIds ?? []);

    cubit.loadTeacherControllers(widget.teacher);
    cubit.loadAssignedStudents(widget.teacher?.assignedStudentIds ?? []);

    familySelection = SchoolYearsModel.getFamilies();
    assignedStudyYearSelection =
        SchoolYearsModel.allYears[widget.teacher?.assignedFamily] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final selectedFamily =
        familySelection.contains(cubit.teacherFamilySelectedValue)
        ? cubit.teacherFamilySelectedValue
        : null;
    final selectedAssignedYear =
        SchoolYearsModel.allYears[selectedFamily] ?? [];
    final selectedStudyYear =
        selectedAssignedYear.contains(cubit.teacherAssignedYearSelectedValue)
        ? cubit.teacherAssignedYearSelectedValue
        : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: MainButton(
            title: 'حفظ',
            onPressed: () async {
              if (cubit.formkey.currentState?.validate() ?? false) {
                final teacherName = cubit.teacherNameController.text.trim();
                final teacherFamily = cubit.teacherFamilySelectedValue;
                final teacherAssignedYear =
                    cubit.teacherAssignedYearSelectedValue;

                // Update existing teacher
                cubit.updateTeacher(
                  newTeacher: widget.teacher!.copyWith(
                    name: teacherName,
                    assignedFamily: teacherFamily,
                    assignedStudyLevel: teacherAssignedYear,
                    role: cubit.teacherAssignedRoleSelectedValue,
                    assignedStudentIds: updatedIds ?? [],
                  ),
                );
              }
            },
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadingState) {
            showLoadingDialog(context);
          } else if (state is ProfileSuccessState) {
            pop(context);
            showMyDialoge(
              context,
              widget.teacher == null ? 'تمت الاضافة بنجاح' : 'تم التعديل بنجاح',
              type: DialogType.success,
            );
            pop(context); // Close the edit screen after success
          } else if (state is ProfileErrorState) {
            pop(context);
            showMyDialoge(context, state.message, type: DialogType.error);
          }
        },
        builder: (context, state) {
          assignedStudyYearSelection =
              SchoolYearsModel.allYears[selectedFamily] ?? [];
          return Column(
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
                          widget.teacher == null
                              ? 'اضافة خادم جديد'
                              : 'تعديل بيانات الخادم',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
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
                            label: 'اسم الخادم',
                            icon: Icons.person_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل اسم الخادم',
                              controller: cubit.teacherNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'ارجوك ادخل اسم الخادم';
                                }
                                return null;
                              },
                            ),
                          ),

                          const Gap(16),

                          // family selection dropdown
                          CustomFormField(
                            label: " الاسرة",
                            icon: Icons.image_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              value: selectedFamily,
                              hint: Text(
                                '${widget.teacher?.assignedFamily}',
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
                                return familySelection.map((item) {
                                  return Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: familySelection.map((item) {
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
                                  cubit.teacherFamilySelectedValue = value;
                                  cubit.teacherAssignedYearSelectedValue = null;
                                });
                              },
                            ),
                          ),

                          const Gap(16),

                          // assigned study year selection dropdown
                          CustomFormField(
                            label: "السنة المسئول عنها",
                            icon: Icons.image_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              value: selectedStudyYear,
                              hint: Text(
                                '${widget.teacher?.assignedStudyLevel}',
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
                                return assignedStudyYearSelection.map((item) {
                                  return Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: assignedStudyYearSelection.map((item) {
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
                                setState(
                                  () => cubit.teacherAssignedYearSelectedValue =
                                      value,
                                );
                              },
                            ),
                          ),

                          const Gap(24),

                          // role dropdown
                          CustomFormField(
                            label: ' الدور',
                            icon: Icons.image_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              value: cubit.teacherAssignedRoleSelectedValue,
                              hint: Text(
                                '${widget.teacher?.role}',
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
                                return roleSelection.map((item) {
                                  return Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: roleSelection.map((item) {
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
                                setState(
                                  () => cubit.teacherAssignedRoleSelectedValue =
                                      value,
                                );
                              },
                            ),
                          ),
                          const Gap(16),

                          CustomFormField(
                            label: 'المخدومين المُكلف بهم',
                            icon: Icons.group_rounded,
                            child: BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, state) {
                                if (state
                                    is ProfileAssignedStudentsLoadedState) {
                                  return AssignedStudentsShowcase(
                                    students: state.students,
                                    onEditPressed: () async {
                                      updatedIds = await pushTo(
                                        context,
                                        Routes.editTeacherStudents,
                                        extra: widget.teacher!.copyWith(
                                          assignedStudentIds: state.students
                                              .map((s) => s.uid!)
                                              .toList(),
                                        ),
                                      );
                                      if (updatedIds != null) {
                                        context
                                            .read<ProfileCubit>()
                                            .loadAssignedStudents(
                                              updatedIds ?? [],
                                            );
                                      }
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AssignedStudentsShowcase extends StatelessWidget {
  final List<StudentModel> students;
  final VoidCallback? onEditPressed; // opens the full edit screen

  const AssignedStudentsShowcase({
    super.key,
    required this.students,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (students.isNotEmpty)
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: students.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
                final student = students[index];
                return SizedBox(
                  width: 100, // fixed width for horizontal
                  child: StudentCard(student: student),
                );
              },
            ),
          ),
        if (students.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'لا يوجد طلاب مسندين',
              style: TextStyles.getSize16(color: AppColors.greyColor),
            ),
          ),
        const Gap(8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('تعديل المخدومين المُكلف بهم'),
            onPressed: onEditPressed,
          ),
        ),
      ],
    );
  }
}
