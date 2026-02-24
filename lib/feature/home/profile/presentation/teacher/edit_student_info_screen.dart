import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/home/data/lists/1st_prep_students_list.dart';
import 'package:saint_paul/feature/home/data/lists/3rd_prep_students_list.dart';
import 'package:saint_paul/feature/home/data/widgets/filter_chip.dart';
import 'package:saint_paul/feature/home/data/widgets/header_icon_button.dart';

class StudentProfileEditScreen extends StatefulWidget {
  const StudentProfileEditScreen({super.key});

  @override
  State<StudentProfileEditScreen> createState() =>
      _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends State<StudentProfileEditScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 5,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseProvider.streamedSortStudentsByTotalTayo(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(
          //     child: CircularProgressIndicator(color: AppColors.primaryColor),
          //   );
          // }

          if (snapshot.hasError) {
            log('streamedSortStudentsByTotalTayo error: ${snapshot.error}');
            return Center(
              child: Text(
                'حدث خطا في تحميل المخدومين',
                style: TextStyles.getSize18(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          allStudents = docs
              .map(
                (doc) => StudentModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          filteredStudents = allStudents;

          return SafeArea(
            child: Column(
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
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFFFFD700),
                              size: 24,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            'حسابات المخدومين',
                            style: TextStyles.getSize24(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          HeaderIconButton(
                            icon: Icons.add_rounded,
                            onTap: () {
                              pushTo(context, Routes.addEditNewStudentScreen);

                              // var futures = firstPrepStudentsList.map((
                              //   student,
                              // ) {
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
                              setState(() {
                                searchText = '';
                                searchNotifier.value = searchText;
                              });
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
                            searchNotifier.value = searchText;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Filter chips ─────────────────────────────────────────
                Padding(
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
                              FilteredChip(
                                label: 'الكل',
                                selected: selectedYear == null,
                                onTap: () =>
                                    setState(() => selectedYear = null),
                              ),
                              const Gap(8),
                              FilteredChip(
                                label: 'اولي اعدادي',
                                selected: selectedYear == 'اولي اعدادي',
                                onTap: () => setState(
                                  () => selectedYear = 'اولي اعدادي',
                                ),
                              ),
                              const Gap(8),
                              FilteredChip(
                                label: 'تانيه اعدادي',
                                selected: selectedYear == 'تانيه اعدادي',
                                onTap: () => setState(
                                  () => selectedYear = 'تانيه اعدادي',
                                ),
                              ),
                              const Gap(8),
                              FilteredChip(
                                label: 'ثالثة اعدادي',
                                selected: selectedYear == 'ثالثة اعدادي',
                                onTap: () => setState(
                                  () => selectedYear = 'ثالثة اعدادي',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(14),

                // ── List ─────────────────────────────────────────────────
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ValueListenableBuilder(
                      valueListenable: searchNotifier,
                      builder: (context, searchText, _) {
                        filteredStudents =
                            searchText.isEmpty && selectedYear == null
                            ? allStudents
                            : allStudents.where((student) {
                                final name = student.name ?? '';
                                final studyLevel = student.studyLevel ?? '';
                                return name.contains(searchText) &&
                                    studyLevel.contains(selectedYear ?? '');
                              }).toList();

                        if (filteredStudents.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: AppColors.accentColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                const Gap(12),
                                Text(
                                  'لا يوجد مخدومون',
                                  style: TextStyles.getSize18(
                                    color: AppColors.accentColor.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filteredStudents.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            //   final isTopThree = rankColor != null;

                            return GestureDetector(
                              onTap: () {
                                pushTo(
                                  context,
                                  Routes.addEditNewStudentScreen,
                                  extra: student,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,

                                  child: Column(
                                    children: [
                                      // image circular avatar
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: AppColors.primaryColor
                                            .withValues(alpha: 0.08),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyles.getSize16(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const Gap(3),
                                      // Name & level
                                      Text(
                                        student.name ?? 'بدون اسم',
                                        style: TextStyles.getSize18(
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if ((student.studyLevel ?? '')
                                          .isNotEmpty) ...[
                                        const Gap(2),
                                        Text(
                                          student.studyLevel!,
                                          style: TextStyles.getSize12(
                                            color: AppColors.accentColor
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
