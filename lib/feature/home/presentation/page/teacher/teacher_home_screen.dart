import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
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

  Color? _rankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700);
    if (index == 1) return const Color(0xFFB0B0B0);
    if (index == 2) return const Color(0xFFCD7F32);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseProvider.streamedSortStudentsByTotalTayo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

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

          return Column(
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
                            Icons.home_rounded,
                            color: AppColors.whiteColor,
                            size: 24,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'الصفحة الرئيسية',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        // Add student button
                        _HeaderIconButton(
                          icon: Icons.add_rounded,
                          onTap: () =>
                              pushTo(context, Routes.addNewStudentScreen),
                        ),
                        const Gap(8),
                        // Logout button
                        _HeaderIconButton(
                          svgAsset: AppAssets.logoutSvg,
                          onTap: () => showSignOutDialog(context),
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
                              AppColors.whiteColor.withValues(alpha: 0.7),
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
                            color: AppColors.whiteColor.withValues(alpha: 0.7),
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

              // ── Filter chips ────────────────────────────────────────
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
                            _FilterChip(
                              label: 'الكل',
                              selected: selectedYear == null,
                              onTap: () => setState(() => selectedYear = null),
                            ),
                            const Gap(8),
                            _FilterChip(
                              label: 'اولي اعدادي',
                              selected: selectedYear == 'اولي اعدادي',
                              onTap: () =>
                                  setState(() => selectedYear = 'اولي اعدادي'),
                            ),
                            const Gap(8),
                            _FilterChip(
                              label: 'تانيه اعدادي',
                              selected: selectedYear == 'تانيه اعدادي',
                              onTap: () =>
                                  setState(() => selectedYear = 'تانيه اعدادي'),
                            ),
                            const Gap(8),
                            _FilterChip(
                              label: 'ثالثة اعدادي',
                              selected: selectedYear == 'ثالثة اعدادي',
                              onTap: () =>
                                  setState(() => selectedYear = 'ثالثة اعدادي'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(14),

              // ── Student list ────────────────────────────────────────
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

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final rankColor = _rankColor(index);
                          final isTopThree = rankColor != null;
                          final tayo = student.totalTayo ?? 0;

                          return GestureDetector(
                            onTap: () => pushTo(
                              context,
                              Routes.studentDetailsScreen,
                              extra: student,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isTopThree
                                    ? rankColor!.withValues(alpha: 0.07)
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isTopThree
                                      ? rankColor!.withValues(alpha: 0.4)
                                      : AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                  width: isTopThree ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isTopThree
                                        ? rankColor!.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.04),
                                    blurRadius: isTopThree ? 12 : 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Rank badge
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isTopThree
                                          ? rankColor!.withValues(alpha: 0.15)
                                          : AppColors.primaryColor.withValues(
                                              alpha: 0.08,
                                            ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isTopThree
                                            ? rankColor!.withValues(alpha: 0.5)
                                            : AppColors.primaryColor.withValues(
                                                alpha: 0.15,
                                              ),
                                      ),
                                    ),
                                    child: Center(
                                      child: isTopThree
                                          ? Icon(
                                              Icons.emoji_events_rounded,
                                              size: 20,
                                              color: rankColor,
                                            )
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyles.getSize16(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const Gap(12),
                                  // Name & study level
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                  // Tayo score badge
                                  if (tayo > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTopThree
                                            ? rankColor!.withValues(alpha: 0.15)
                                            : AppColors.primaryColor.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$tayo',
                                        style: TextStyles.getSize16(
                                          color: isTopThree
                                              ? rankColor!
                                              : AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  const Gap(6),
                                  Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 14,
                                    color: AppColors.accentColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({this.icon, this.svgAsset, required this.onTap});

  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.whiteColor,
                  BlendMode.srcIn,
                ),
              )
            : Icon(icon, color: AppColors.whiteColor, size: 20),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.whiteColor : AppColors.primaryColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
