import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
import 'package:saint_paul/feature/home/data/lists/1st_prep_students_list.dart';
import 'package:saint_paul/feature/home/data/lists/3rd_prep_students_list.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/home/widgets/student_info_edit_builder.dart';
import 'package:saint_paul/feature/profile/widgets/teachers_edit_builder.dart';

class StudentsShowcaseAndEditScreen extends StatefulWidget {
  const StudentsShowcaseAndEditScreen({super.key});

  @override
  State<StudentsShowcaseAndEditScreen> createState() =>
      _StudentsShowcaseAndEditScreenState();
}

class _StudentsShowcaseAndEditScreenState
    extends State<StudentsShowcaseAndEditScreen> {
  var searchController = TextEditingController();
  ValueNotifier<String> searchNotifier = ValueNotifier('');

  String searchText = '';
  String? selectedYear = 'الكل';
  String? userType = LocalHelper.getUserType();

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];
  List<String> filterChipsElements = ['الكل', 'مخدومينى'];
  List<String> roleSelection = [
    'خادم',
    'أمين الخدمة',
    'أمين خدمة التربية الكنسية',
  ];
  List<String> familyfilterElements = ['الكل'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    familyfilterElements.addAll(SchoolYearsModel.getFamilies());

    log('User type in StudentsShowcaseAndEditScreen: $userType');
    log(
      'User study level in StudentsShowcaseAndEditScreen: ${LocalHelper.getUserStudyLevel()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.darkYellowIconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      userType == 'خادم' ? 'حسابات المخدومين' : 'حسابات الخدام',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),
                    userType == 'خادم'
                        ? HeaderIconButton(
                            icon: Icons.add_rounded,
                            onTap: () {
                              pushTo(context, Routes.addEditNewStudentScreen);

                              // var futures = thirdPrepStudentList.map((student) {
                              //   return FirebaseProvider.createStudent(student);
                              // });
                              // Future.wait(futures);
                            },
                          )
                        : SizedBox(),
                    Gap(5),
                    HeaderIconButton(
                      icon: Icons.rule_rounded,
                      onTap: () {
                        pushTo(context, Routes.missCheckStudentScreen);

                        // var futures = thirdPrepStudentList.map((student) {
                        //   return FirebaseProvider.createStudent(student);
                        // });
                        // Future.wait(futures);
                      },
                    ),
                  ],
                ),
                const Gap(18),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomTextField(
                    controller: searchController,
                    hintText: userType == 'خادم'
                        ? "بحث عن مخدوم..."
                        : "بحث عن خادم...",
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
                        setState(() {
                          searchText = '';
                          searchNotifier.value = searchText;
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                    onChanged: (value) {
                      searchText = value.trim();
                      searchNotifier.value = searchText;
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────
          if (userType == 'خادم') ...{
            filterChipBuilder(filterChipsElements),
          } else if (userType == 'أمين خدمة التربية الكنسية') ...{
            filterChipBuilder(familyfilterElements),
          },
          const Gap(14),

          // ── List ─────────────────────────────────────────────────
          userType == 'خادم'
              ? Expanded(
                  child: StudentInfoEditbuilder(
                    searchNotifier: searchNotifier,
                    selectedYear: selectedYear,
                  ),
                )
              : Expanded(
                  child: TeacherInfoEditbuilder(
                    searchNotifier: searchNotifier,
                    selectedFamily: selectedYear,
                  ),
                ),
        ],
      ),
    );
  }

  Padding filterChipBuilder(List<String> FilterElements) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
                  ...FilterElements.map((year) {
                    return Row(
                      children: [
                        FilteredChip(
                          label: year,
                          selected: selectedYear == year,
                          onTap: () => setState(() => selectedYear = year),
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
    );
  }
}
