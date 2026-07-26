import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/profile/widgets/miss_check_list_builder.dart';

/// Teacher-facing screen for tracking pastoral check-ins (افتقاد).
///
/// Shows every student who is still "due" for a check this week; ticking
/// the checkbox marks them as visited (writes `lastMissCheck` to Firestore)
/// and removes them from the list. The list naturally repopulates the
/// following week since due-ness is derived from `lastMissCheck` itself.
class StudentsMissCheckScreen extends StatefulWidget {
  const StudentsMissCheckScreen({super.key});

  @override
  State<StudentsMissCheckScreen> createState() =>
      _StudentsMissCheckScreenState();
}

class _StudentsMissCheckScreenState extends State<StudentsMissCheckScreen> {
  final searchController = TextEditingController();
  final searchNotifier = ValueNotifier('');

  String? selectedFilter = 'مخدومينى';

  @override
  void dispose() {
    searchController.dispose();
    searchNotifier.dispose();
    super.dispose();
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
                        Icons.favorite_rounded,
                        color: AppColors.darkYellowIconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'متابعة الافتقاد',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
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
          Gap(25),
          // ── List ─────────────────────────────────────────────────
          Expanded(child: MissCheckListBuilder(searchNotifier: searchNotifier)),
        ],
      ),
    );
  }
}
