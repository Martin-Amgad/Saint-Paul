import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';
import 'package:saint_paul/feature/groups/widgets/student_group_list_builder.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';

import '../../../../auth/data/models/school_years_model.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final searchController = TextEditingController();
  final ValueNotifier<String> searchNotifier = ValueNotifier('');

  String searchText = '';
  String? selectedYear = 'الكل';
  List<String> selectedStudentIds = [];
  List<String> filterChipsElements = ['الكل'];

  List<StudentModel> students = [];
  GroupModel? group;
  int? totalTayo;
  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().fetchStudents(
      LocalHelper.getUserFamily(),
      LocalHelper.getUserChurchName(),
    );
    filterChipsElements
      ..addAll(SchoolYearsModel.allYears[LocalHelper.getUserFamily()] ?? []);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<GroupCubit>();
    final topPadding = MediaQuery.paddingOf(context).top * 0.85;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is StudentsLoadedSuccessState) {
              return MainButton(
                title: 'حفظ المجموعة',
                onPressed: () async {
                  if ((cubit.formKey.currentState?.validate() ?? true) &&
                      selectedStudentIds.isNotEmpty) {
                    log(
                      'Creating group with name: ${cubit.groupNameController.text}, selected students: $selectedStudentIds, total tayo: ${cubit.groupTotalTayo}, study level: ${selectedYear ?? 'الكل'}',
                    );
                    await cubit.createGroup(
                      selectedStudentIds,
                      selectedYear ?? 'الكل',
                    );
                  } else if (selectedStudentIds.isEmpty) {
                    showMyDialoge(
                      context,
                      'يرجى اختيار مخدوم واحد على الأقل',
                      type: DialogType.error,
                    );
                  }
                },
              );
            }
            return MainButton(
              title: 'حفظ المجموعة',
              onPressed: () {},
              // ← replace null with empty function temporarily
            );
          },
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(15),

                  Row(
                    children: [
                      CustomBackButton(),
                      const Gap(12),
                      Text(
                        'إنشاء مجموعة',
                        style: TextStyles.getSize24(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // Group name input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomTextField(
                      controller: cubit.groupNameController,
                      hintText: "اسم المجموعة...",
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8),
                        child: Icon(
                          Icons.group_rounded,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      errorStyle: TextStyles.getSize12(
                        color: AppColors.whiteColor.withValues(alpha: 0.8),
                      ),
                      validator: (p0) {
                        if (p0 == null || p0.trim().isEmpty) {
                          return 'يرجى إدخال اسم المجموعة';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(12),
                  // Search input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomTextField(
                      controller: searchController,
                      hintText: "بحث عن مخدوم...",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: SvgPicture.asset(
                          AppAssets.searchSvg,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchController.clear();
                          searchNotifier.value = '';
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                      onChanged: (value) {
                        searchNotifier.value = value.trim();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Selected count indicator ─────────────────────────────
            if (selectedStudentIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'تم اختيار ${selectedStudentIds.length} مخدوم',
                    style: TextStyles.getSize16(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // ── Filter chips ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    'فلتر:',
                    style: TextStyles.getSize16(
                      color: AppColors.accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...filterChipsElements.map((year) {
                            return Row(
                              children: [
                                FilteredChip(
                                  label: year,
                                  selected: selectedYear == year,
                                  onTap: () =>
                                      setState(() => selectedYear = year),
                                ),
                                Gap(5),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(14),

            // ── Student list ─────────────────────────────────────────
            BlocConsumer<GroupCubit, GroupState>(
              listener: (context, state) {
                if (state is GroupLoadingState) {
                  showLoadingDialog(context);
                } else if (state is GroupErrorState) {
                  showMyDialoge(context, state.message, type: DialogType.error);
                } else if (state is GroupSuccessState) {
                  pop(context);
                  showMyDialoge(
                    context,
                    state.message ?? 'تم إنشاء المجموعة بنجاح.',
                    type: DialogType.success,
                  );
                  pop(context);
                }
              },
              builder: (context, state) {
                if (state is StudentsLoadedSuccessState) {
                  students = state.students;
                }
                return students.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Expanded(
                        child: StudentGroupListBuilder(
                          searchNotifier: searchNotifier,
                          selectedYear: selectedYear,
                          students: students,
                          selectedStudentIds: selectedStudentIds,
                          onStudentToggled: (studentId, totalTayo) {
                            log(
                              'Current selected student IDs: $selectedStudentIds',
                            );
                            setState(() {
                              if (selectedStudentIds.contains(studentId)) {
                                selectedStudentIds.remove(studentId);
                                cubit.groupTotalTayo -= totalTayo;
                              } else {
                                selectedStudentIds.add(studentId);
                                cubit.groupTotalTayo += totalTayo;
                              }
                            });
                            log(
                              'Current selected student IDs: $selectedStudentIds',
                            );
                            log(
                              'Current group total tayo: ${cubit.groupTotalTayo}',
                            );
                          },
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
