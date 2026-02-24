import 'package:flutter/material.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/home/widgets/student_info_edit_builder.dart';

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
      body: SafeArea(
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
                          color: AppColors.whiteColor.withValues(alpha: 0.15),
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
                            onTap: () => setState(() => selectedYear = null),
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

            // ── List ─────────────────────────────────────────────────
            StudentInfoEditbuilder(
              searchNotifier: searchNotifier,
              selectedYear: selectedYear,
            ),
          ],
        ),
      ),
    );
  }
}
