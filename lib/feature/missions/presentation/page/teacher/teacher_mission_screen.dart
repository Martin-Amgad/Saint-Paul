import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/missions/widgets/student_missions_list.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';

class TeacherMissionScreen extends StatefulWidget {
  const TeacherMissionScreen({super.key});

  @override
  State<TeacherMissionScreen> createState() => _TeacherMissionScreenState();
}

class _TeacherMissionScreenState extends State<TeacherMissionScreen> {
  @override
  void initState() {
    context.read<MissionCubit>().fetchMissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // ── Header always visible ──────────────────────────────
          BlocBuilder<MissionCubit, MissionState>(
            builder: (context, state) {
              final count = state is MissionsLoadedState
                  ? state.missions?.length ?? 0
                  : 0;
              return Container(
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
                            color: AppColors.yellowIconColor,
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
                        const Spacer(),
                        HeaderIconButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            pushTo(context, Routes.createMissionScreen).then((
                              _,
                            ) {
                              context.read<MissionCubit>().fetchMissions();
                            });
                          },
                        ),
                      ],
                    ),
                    const Gap(14),
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
                            '$count مهام لهذا الأسبوع',
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
              );
            },
          ),

          // ── Content changes based on state ────────────────────
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
                          'لا توجد مهام بعد',
                          style: TextStyles.getSize18(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'اضغط على زر الإضافة لإنشاء مهمة جديدة',
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
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: StudentMissionsList(
                      missions: state.missions,
                      isStudent: false,
                    ),
                  );
                } else if (state is MissionErrorState) {
                  return Center(child: Text(state.message));
                } else {
                  return Column(
                    children: [
                      Gap(MediaQuery.of(context).size.height * 0.35),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
