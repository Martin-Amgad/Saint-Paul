import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/data/models/student_mission_model.dart';

class StudentMissionScreen extends StatefulWidget {
  const StudentMissionScreen({super.key});

  @override
  State<StudentMissionScreen> createState() => _StudentMissionScreenState();
}

class _StudentMissionScreenState extends State<StudentMissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
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
                  color: AppColors.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: Offset.zero,
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
                      child: Icon(
                        Icons.assignment_rounded,
                        color: AppColors.whiteColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'المهام',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                // Summary pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.format_list_bulleted_rounded,
                        color: AppColors.whiteColor.withValues(alpha: 0.8),
                        size: 18,
                      ),
                      const Gap(8),
                      Text(
                        '10 مهام هذا الأسبوع',
                        style: TextStyles.getSize16(
                          color: AppColors.whiteColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Mission list ─────────────────────────────────────────────
          Expanded(child: StudentMissionModel()),
        ],
      ),
    );
  }
}
