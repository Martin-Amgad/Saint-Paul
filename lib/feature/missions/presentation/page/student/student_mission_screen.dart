import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/widgets/student_missions_list.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';

class StudentMissionScreen extends StatefulWidget {
  const StudentMissionScreen({super.key});

  @override
  State<StudentMissionScreen> createState() => _StudentMissionScreenState();
}

class _StudentMissionScreenState extends State<StudentMissionScreen> {
  int selectedIndex = 0;
  List<MissionModel>? missions;
  List<String>? acceptedMissions;
  List<MissionModel>? myAvailableMissions;

  @override
  void initState() {
    context.read<MissionCubit>().fetchMissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<MissionCubit, MissionState>(
        listener: (context, state) {
          if (state is MissionsLoadedState) {
            missions = state.missions;
            log('Missions loaded: ${missions?.length ?? 0} missions');
            acceptedMissions = state.acceptedMissions;
            myAvailableMissions = missions
                ?.where(
                  (mission) =>
                      !(acceptedMissions?.contains(mission.mid) ?? false),
                )
                .toList();
            log(
              'Available missions for student: ${myAvailableMissions?.length ?? 0}',
            );
            log(
              'Accepted missions for student: ${acceptedMissions?.length ?? 0}',
            );
            log('acceptedMissions: $acceptedMissions');
          } else if (state is MissionErrorState) {
            log('Error loading missions: ${state.message}');
          }
        },
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
              Gap(8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SlidingSelector(
                        options: const ['المهام المتاحة', 'مهامي'],
                        selectedIndex: selectedIndex,
                        onChanged: (index) =>
                            setState(() => selectedIndex = index),
                      ),
                      Gap(8),
                      BlocBuilder<MissionCubit, MissionState>(
                        builder: (context, state) {
                          if (state is MissionLoadingState) {
                            return Column(
                              children: [
                                Gap(MediaQuery.of(context).size.height * 0.15),
                                CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            );
                          }
                          return Expanded(
                            child: selectedIndex == 0
                                ? AvailableMissionsBuilder(
                                    missions: myAvailableMissions,
                                    isAvailable: true,
                                  )
                                : acceptedMissions != null &&
                                      acceptedMissions!.isNotEmpty
                                ? StudentMissionsList(
                                    missions: missions
                                        ?.where(
                                          (mission) => acceptedMissions!
                                              .contains(mission.mid),
                                        )
                                        .toList(),
                                    isStudent: true,
                                    isAvailable: false,
                                  )
                                : Center(
                                    child: Text(
                                      'لا توجد مهام مقبولة حالياً، ',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.getSize16(
                                        color: AppColors.accentColor.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                      // Expanded(
                      //   child: BlocBuilder<MissionCubit, MissionState>(
                      //     builder: (context, state) {
                      //       if (state is MissionsLoadedState) {
                      //         if (selectedIndex == 0) {
                      //           return AvailableMissionsBuilder(
                      //             missions: state.missions,
                      //           );
                      //         } else {
                      //           return StudentMissionsList(
                      //             missions: state.missions,
                      //             isStudent: true,
                      //           );
                      //         }
                      //       }
                      //     },
                      //   ),
                      // ),
                    ],
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

class AvailableMissionsBuilder extends StatelessWidget {
  const AvailableMissionsBuilder({super.key, this.missions, this.isAvailable});
  final List<MissionModel>? missions;
  final bool? isAvailable;
  @override
  Widget build(BuildContext context) {
    if (missions?.isEmpty ?? true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 52,
              color: AppColors.primaryColor.withValues(alpha: 0.4),
            ),
          ),
          const Gap(20),

          Text(
            'لا توجد مهام متاحة حالياً، تابع لاحقاً',
            textAlign: TextAlign.center,
            style: TextStyles.getSize16(
              color: AppColors.accentColor.withValues(alpha: 0.45),
            ),
          ),
        ],
      );
    }
    return StudentMissionsList(
      missions: missions,
      isStudent: true,
      isAvailable: isAvailable,
    );
  }
}

class SlidingSelector extends StatefulWidget {
  const SlidingSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<SlidingSelector> createState() => _SlidingSelectorState();
}

class _SlidingSelectorState extends State<SlidingSelector> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth =
            constraints.maxWidth - 8; // subtract padding (4 on each side)
        final itemWidth = totalWidth / widget.options.length;

        return Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Stack(
            children: [
              // ── Sliding pill ──────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                right: widget.selectedIndex * (itemWidth - 2),

                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Labels ────────────────────────────────────
              Row(
                children: List.generate(widget.options.length, (index) {
                  final isSelected = index == widget.selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onChanged(index);
                        log('Selected index: $index');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyles.getSize16(
                            color: isSelected
                                ? AppColors.whiteColor
                                : AppColors.accentColor.withValues(alpha: 0.5),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          child: Text(
                            widget.options[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
