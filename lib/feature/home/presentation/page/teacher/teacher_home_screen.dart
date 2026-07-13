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
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';
import 'package:saint_paul/feature/home/widgets/add_new_badge_bottom_sheet.dart';
import 'package:saint_paul/feature/home/widgets/admin_password_change_bottom_sheet.dart';
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
  String? selectedYear = 'الكل';

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];
  List<String> filterChipsElements = [];

  String? userType = 'خادم';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userType = LocalHelper.getUserType();
    log('TeacherHomeScreen userType: $userType');
    filterChipsElements =
        SchoolYearsModel.allYears[LocalHelper.getUserFamily()] ?? [];
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
      body: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeErrorState) {
            showMyDialoge(context, state.message, type: DialogType.error);
          } else if (state is HomeBadgeCreationSuccessState) {
            showMyDialoge(
              context,
              'تم إنشاء الوسام بنجاح.',
              type: DialogType.success,
            );
          }
        },
        child: Column(
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
                      ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
                      ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
                      // to add new Field to all documents in the Students collection

                      // HeaderIconButton(
                      //   icon: Icons.add_rounded,
                      //   onTap: () {
                      //     log(
                      //       'Adding new church to all documents in the Students collection',
                      //     );
                      //     // context.read<HomeCubit>().addChurchToAllDocs(
                      //     //   "اعدادي",
                      //     // );
                      //   },
                      // ),
                      // Gap(30),
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

                      //create new badge button
                      HeaderIconButton(
                        pngAsset: AppAssets.addBadgeIcon,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.backgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<HomeCubit>(),
                              child: AddNewBadgeSheet(),
                            ),
                          );

                          // var futures = thirdPrepStudentList.map((student) {
                          //   return FirebaseProvider.createStudent(student);
                          // });
                          // Future.wait(futures);
                        },
                      ),

                      // change password button
                      if (userType == "أمين خدمة التربية الكنسية") ...[
                        Gap(12),

                        HeaderIconButton(
                          svgAsset: AppAssets.lockSvg,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.backgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => AdminPasswordChangeBottomSheet(),
                            );
                          },
                        ),
                      ],
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
                          Gap(5),
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

            // ── Student list ────────────────────────────────────────
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: StudentList(
                  searchText: searchText.toLowerCase(),
                  filterSelection: selectedYear ?? 'الكل',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
