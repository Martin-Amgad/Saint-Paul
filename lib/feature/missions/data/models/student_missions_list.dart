import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';

class StudentMissionsList extends StatelessWidget {
  const StudentMissionsList({
    super.key,
    required this.missions,
    required this.isStudent,
  });
  final List<MissionModel>? missions;
  final bool? isStudent;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: missions?.length ?? 0,
      separatorBuilder: (_, _) => const Gap(12),
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            if (isStudent == false) {
              sureToDeleteMissionDialog(
                context,
                title: 'هل أنت متأكد من حذف المهمة؟',
                content:
                    'سيتم حذف المهمة من جميع الطلاب ولن تتمكن من استعادتها مرة أخرى.',
                mainButtonText: 'حذف',
                mainButtonOnConfirm: () {
                  context.read<MissionCubit>().deleteMission(
                    missions?[index].mid ?? '',
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
            isStudent == true
                ? pushTo(
                    context,
                    Routes.missionDetailsScreen,
                    extra: missions?[index],
                  )
                : null;
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
                              missions?[index].title ?? '',
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
                        missions?[index].description ?? '',
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
                      // Reward row
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.yellowIconColor,
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
                            '${missions?[index].reward ?? 0} طايو',
                            style: TextStyles.getSize16(
                              color: AppColors.yellowIconColor,
                              fontWeight: FontWeight.w700,
                            ),
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
    );
  }
}
