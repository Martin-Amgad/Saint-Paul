import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, this.group});
  final GroupModel? group;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  @override
  void initState() {
    super.initState();
    log('Fetching student group for user ID: ${LocalHelper.getUserId()}');
    if (widget.group == null) {
      context.read<GroupCubit>().fetchStudentGroup(LocalHelper.getUserId());
    } else {
      log('User is not a student, skipping group fetch.');
      context.read<GroupCubit>().techersGroupDetails(widget.group);
      context.read<GroupCubit>().fetchAndUpdateTotalTayo(widget.group);
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<GroupCubit>();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupLoadingState) {
            showLoadingDialog(context);
          }

          if (state is GroupErrorState) {
            showMyDialoge(context, state.message, type: DialogType.error);
          }
        },
        builder: (context, state) {
          // if (state is GroupLoadingState) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          // ── Not assigned to any group ────────────────────────────
          if (state is GroupNotAssignedState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_off_rounded,
                    size: 64,
                    color: AppColors.accentColor.withValues(alpha: 0.2),
                  ),
                  const Gap(12),
                  Text(
                    'لم يتم تعيينك في مجموعة بعد',
                    style: TextStyles.getSize18(
                      color: AppColors.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Group loaded ─────────────────────────────────────────
          if (state is StudentsLoadedSuccessState) {
            final students = state.students;
            final group = state.group;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
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
                      CustomBackButton(),
                      const Gap(12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: AppColors.darkYellowIconColor,
                              size: 24,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              group?.name ?? '',
                              style: TextStyles.getSize24(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_rounded,
                                  color: AppColors.whiteColor,
                                  size: 16,
                                ),
                                const Gap(6),
                                Text(
                                  '${students.length} مخدوم',
                                  style: TextStyles.getSize16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.darkYellowIconColor,
                                  size: 16,
                                ),
                                const Gap(6),
                                Text(
                                  '${group?.totalTayo ?? 0} طايو',
                                  style: TextStyles.getSize16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(16),

                // ── Student grid ───────────────────────────────────
                Expanded(
                  child: students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'لا يوجد مخدومون في هذه المجموعة',
                                style: TextStyles.getSize18(
                                  color: AppColors.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: students.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.1,
                              ),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: AppColors.primaryColor
                                        .withValues(alpha: 0.08),
                                    child: ClipOval(
                                      child:
                                          student.avatarUrl != null &&
                                              student.avatarUrl!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: student.avatarUrl ?? '',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.person_rounded,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 30,
                                                      ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              color: AppColors.primaryColor,
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    student.name ?? 'بدون اسم',
                                    style: TextStyles.getSize18(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  if ((student.studyLevel ?? '')
                                      .isNotEmpty) ...[
                                    const Gap(2),
                                    Text(
                                      student.studyLevel!,
                                      style: TextStyles.getSize12(
                                        color: AppColors.accentColor.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Gap(4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: AppColors.darkYellowIconColor,
                                        size: 12,
                                      ),
                                      const Gap(4),
                                      Text(
                                        '${student.totalTayo ?? 0}',
                                        style: TextStyles.getSize12(
                                          color: AppColors.darkYellowIconColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        },
      ),
    );
  }
}
