import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';

class StudentMissionsList extends StatefulWidget {
  const StudentMissionsList({
    super.key,
    required this.missions,
    required this.isStudent,
    this.isAvailable,
  });
  final List<MissionModel>? missions;
  final bool? isStudent;
  final bool? isAvailable;

  @override
  State<StudentMissionsList> createState() => _StudentMissionsListState();
}

class _StudentMissionsListState extends State<StudentMissionsList> {
  List<MissionModel>? filteredMissions;
  int daysLeft(MissionModel m) {
    if (m.currentDate == null || m.expireAfter == null) return 0;
    final expireDate = m.currentDate!.add(Duration(days: m.expireAfter!));
    return expireDate.difference(DateTime.now()).inDays;
  }

  @override
  void initState() {
    for (var mission in widget.missions ?? []) {
      log('Mission: ${mission.title}, Days Left: ${daysLeft(mission)}');

      filteredMissions = widget.missions
          ?.where((m) => daysLeft(m) >= 0)
          .toList();
      if (daysLeft(mission) < 0) {
        context.read<MissionCubit>().deleteMission(mission.mid ?? '');
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MissionCubit, MissionState>(
      listener: (context, state) {
        if (state is MissionDeleteSuccessState) {
          showMyDialoge(
            context,
            state.message ?? 'تم حذف المهمة بنجاح.',
            type: DialogType.success,
          );
        } else if (state is MissionErrorState) {
          showMyDialoge(context, state.message, type: DialogType.error);
        }
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: filteredMissions?.length ?? 0,
        separatorBuilder: (_, _) => const Gap(12),
        itemBuilder: (context, index) {
          var reward = filteredMissions?[index].reward ?? '0';
          bool isRewardNumeric = AppRegex.containsOnlyNumbers(reward);
          if (daysLeft(filteredMissions![index]) < 0) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onLongPress: () {
              if (widget.isStudent == false) {
                sureToDeleteMissionDialog(
                  context,
                  title: 'هل أنت متأكد من حذف المهمة؟',
                  content:
                      'سيتم حذف المهمة من جميع الطلاب ولن تتمكن من استعادتها مرة أخرى.',
                  mainButtonText: 'حذف',
                  mainButtonOnConfirm: () {
                    context.read<MissionCubit>().deleteMission(
                      filteredMissions?[index].mid ?? '',
                    );
                    pop(context);
                  },
                  secondaryButtonText: 'إلغاء',
                  secondaryButtonOnConfirm: () {
                    pop(context);
                  },
                );
              }
            },
            onTap: () {
              widget.isStudent == true
                  ? pushTo(
                      context,
                      Routes.missionDetailsScreen,
                      extra: {
                        'mission': filteredMissions?[index],
                        'isAvailable': widget.isAvailable,
                      },
                    ).then((_) {
                      context.read<MissionCubit>().fetchMissions();
                      context.read<ProfileCubit>().loadStudentData(
                        LocalHelper.getUserId(),
                      );
                    })
                  : pushTo(
                      context,
                      Routes.createMissionScreen,
                      extra: filteredMissions?[index],
                    ).then(
                      (value) => context.read<MissionCubit>().fetchMissions(),
                    );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card top accent bar ──────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                filteredMissions?[index].title ?? '',
                                style: TextStyles.getSize18(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                            // Mission number badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: TextStyles.getSize12(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        // Mission description
                        Text(
                          filteredMissions?[index].description ?? '',
                          style: TextStyles.getSize16(
                            color: AppColors.accentColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(12),
                        // Divider
                        Divider(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        const Gap(10),
                        // Reward and enrolled students row
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: AppColors.darkYellowIconColor,
                                  size: 18,
                                ),
                                const Gap(6),
                                Text(
                                  'المكافأة: ',
                                  style: TextStyles.getSize12(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  isRewardNumeric ? '$reward  طايو' : reward,
                                  style: TextStyles.getSize16(
                                    color: AppColors.darkYellowIconColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.group_rounded,
                                  color: AppColors.darkYellowIconColor
                                      .withValues(alpha: 0.9),
                                  size: 18,
                                ),
                                const Gap(6),

                                Text(
                                  ' المشتركين: ',
                                  style: TextStyles.getSize12(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '${filteredMissions?[index].enrolledStudents ?? 0} طالب',
                                  style: TextStyles.getSize16(
                                    color: AppColors.darkYellowIconColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
