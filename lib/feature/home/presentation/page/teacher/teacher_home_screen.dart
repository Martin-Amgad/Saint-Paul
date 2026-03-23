import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/home/widgets/student_list.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';

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

  var newPasswordController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color? rankColor(int index) {
    if (index == 0) return AppColors.darkYellowIconColor;
    if (index == 1) return const Color(0xFFB0B0B0);
    if (index == 2) return const Color(0xFFCD7F32);
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                        Icons.storefront_sharp,
                        color: AppColors.darkYellowIconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'طايو',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),

                    // change password button
                    HeaderIconButton(
                      svgAsset: AppAssets.lockSvg,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                MediaQuery.of(context).viewInsets.bottom + 24,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Handle bar
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Gap(20),
                                  // Title
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.lock_rounded,
                                          color: AppColors.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const Gap(12),
                                      Text(
                                        'تغيير كلمة المرور',
                                        style: TextStyles.getSize18(
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(20),
                                  CustomTextField(
                                    controller: newPasswordController,
                                    hintText: 'كلمة المرور الجديدة',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.primaryColor,
                                    ),
                                    isPassword: true,
                                  ),

                                  const Gap(20),
                                  MainButton(
                                    title: 'تغيير كلمة المرور',
                                    onPressed: () async {
                                      log('Button pressed');
                                      await FirebaseProvider.updateTeacher(
                                        TeacherModel(
                                          uid: '28W6AI0V3SGxJI7qHY73',
                                          adminPin: newPasswordController.text
                                              .trim(),
                                        ),
                                      );
                                      log('Password updated in Firestore');
                                      newPasswordController.clear();
                                      pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Gap(12),
                    // Logout button
                    HeaderIconButton(
                      svgAsset: AppAssets.logoutSvg,
                      onTap: () => showSignOutDialog(context),
                    ),
                  ],
                ),
                const Gap(18),
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
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
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
                        FilteredChip(
                          label: 'الكل',
                          selected: selectedYear == 'الكل',
                          onTap: () => setState(() => selectedYear = 'الكل'),
                        ),
                        const Gap(8),
                        FilteredChip(
                          label: 'اولي اعدادي',
                          selected: selectedYear == 'اولي اعدادي',
                          onTap: () =>
                              setState(() => selectedYear = 'اولي اعدادي'),
                        ),
                        const Gap(8),
                        FilteredChip(
                          label: 'تانيه اعدادي',
                          selected: selectedYear == 'تانيه اعدادي',
                          onTap: () =>
                              setState(() => selectedYear = 'تانيه اعدادي'),
                        ),
                        const Gap(8),
                        FilteredChip(
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
              child: StudentList(
                searchText: searchText,
                filterSelection: selectedYear ?? 'الكل',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
