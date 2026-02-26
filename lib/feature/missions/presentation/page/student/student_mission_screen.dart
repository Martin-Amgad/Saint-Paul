import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/data/models/student_missions_list.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';

class StudentMissionScreen extends StatefulWidget {
  const StudentMissionScreen({super.key});

  @override
  State<StudentMissionScreen> createState() => _StudentMissionScreenState();
}

class _StudentMissionScreenState extends State<StudentMissionScreen> {
  @override
  void initState() {
    context.read<MissionCubit>().fetchMissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<MissionCubit, MissionState>(
        builder: (context, state) {
          int count = state is MissionsLoadedState
              ? state.missions?.length ?? 0
              : 0;

          return Column(
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
                            '$count مهام هذا الأسبوع',
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<MissionCubit, MissionState>(
                  builder: (context, state) {
                    if (state is MissionsLoadedState) {
                      if (state.missions?.isEmpty ?? true) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.07,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                size: 52,
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            const Gap(20),

                            Text(
                              'لا توجد مهام متاحة حالياً، تابع لاحقاً',
                              textAlign: TextAlign.center,
                              style: TextStyles.getSize16(
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Expanded(
                        child: StudentMissionsList(
                          missions: state.missions,
                          isStudent: true,
                        ),
                      );
                    } else if (state is MissionErrorState) {
                      return Center(child: Text(state.message));
                    } else {
                      return Column(
                        children: [
                          Gap(MediaQuery.of(context).size.height * 0.27),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
