import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/home/widgets/student_list.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  var searchController = TextEditingController();
  ValueNotifier<String> searchNotifier = ValueNotifier('');

  String searchText = '';
  String? selectedYear;

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final id = LocalHelper.getUserId();
    log('StudentHomeScreen initState - User ID: $id');
    log(
      'StudentHomeScreen initState - LocalHelper User data: ${LocalHelper.getStudentData()?.name}, studyLevel: ${LocalHelper.getStudentData()?.studyLevel}',
    );
    context.read<HomeCubit>().loadStudentYear(id);

    context.read<HomeCubit>().loadStudentData(LocalHelper.getUserId());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is StudentYearLoaded) {
          LocalHelper.setUserStudyLevel(state.year);
          selectedYear = state.year;
          log('Student year loaded: $selectedYear');
        } else if (state is HomeStudentLoadedState) {
          LocalHelper.setStudentData(state.studentData?.toJsonLocal());
        } else if (state is HomeErrorState) {
          showMyDialoge(context, state.message, type: DialogType.error);
        }
      },
      builder: (context, state) {
        final effectiveSelectedYear = (selectedYear ?? '').trim();
        final isYearLoaded = effectiveSelectedYear.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              // ── Header (extends behind status bar) ──────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  20,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with add + logout
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.leaderboard,
                            color: AppColors.whiteColor,
                            size: 24,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'المتصدرين',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    // Search bar
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
                            setState(() => searchText = '');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          searchText = value.trim();

                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(14),

              // ── Student list ────────────────────────────────────────
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadingState || !isYearLoaded) {
                    return Column(
                      children: [
                        Gap(MediaQuery.of(context).size.height * 0.21),
                        CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ],
                    );
                  }
                  return Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: StudentList(
                        searchText: searchText,
                        filterSelection: effectiveSelectedYear,
                        isStudent: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
