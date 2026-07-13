import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
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
  GroupModel? newGroup;
  String? userType;
  int totalPoints = 0;
  List<StudentModel>? students = [];
  bool isLoading = true;

  // Future<void> loadGroupData() async {
  //     final group = await context.read<GroupCubit>().fetchGroup(widget.group?.gid ?? '');
  //     if (group != null) {
  //       setState(() {
  //         newGroup = group;
  //         totalPoints = group.totalPoints ?? 0;
  //       });
  //     }
  //   }

  @override
  void initState() {
    super.initState();
    var cubit = context.read<GroupCubit>();
    log("Initializing GroupDetailsScreen with group ID: ${widget.group?.gid}");
    log(
      "Group name: ${widget.group?.name}, Total Points: ${widget.group?.totalPoints}",
    );

    //fetching group data
    totalPoints = widget.group?.totalPoints ?? 0;
    newGroup = widget.group;
    // students = widget.group?.students?.map((studentId) {
    //   return StudentModel(uid: studentId);
    // }).toList();
    userType = LocalHelper.getUserType();
    log('Fetching student group for user ID: ${LocalHelper.getUserId()}');
    if (userType == "مخدوم") {
      cubit.fetchAndCheckStudentGroup(LocalHelper.getUserId());
    } else {
      log('User is not a student, skipping group fetch.');
      cubit.teachersGroupDetails(widget.group);
      cubit.fetchAndUpdateTotalTayo(widget.group);
    }

    log('User type: $userType');
  }

  @override
  Widget build(BuildContext context) {
    log("GroupDetailsScreen build. totalPoints = $totalPoints");
    // final students = state.students;
    // final group = state.group;
    var cubit = context.read<GroupCubit>();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          log("Current state: ${state.runtimeType}");

          if (state is GroupLoadingState) {
            isLoading = true;
          }

          ///////// to be modified/////////////////////////////////////////////
          // ── Not assigned to any group ────────────────────────────
          if (state is GroupNotAssignedState) {
            isLoading = false;
          }
          if (state is StudentsLoadedSuccessState) {
            isLoading = false;
            students = state.students;
            log(
              "Fetched students for group ${state.group?.gid}: ${students?.length ?? 0} students",
            );
            // i want to print the students content

            newGroup = state.group;
            totalPoints = state.group?.totalPoints ?? 0;
          }
          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────
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
                    Row(
                      children: [
                        userType == "مخدوم"
                            ? Container(
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
                              )
                            : CustomBackButton(
                                onTap: () {
                                  pop(context, totalPoints);
                                },
                              ),

                        // const Gap(12),
                        const Gap(12),
                        Expanded(
                          child: newGroup?.name == null
                              ? Text(
                                  "",
                                  style: TextStyles.getSize18(
                                    fontSize: 20,
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  newGroup?.name ?? 'بدون اسم',
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
                            color: AppColors.whiteColor.withValues(alpha: 0.15),
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
                                '${newGroup?.students?.length ?? 0} مخدوم',
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
                            color: AppColors.whiteColor.withValues(alpha: 0.15),
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
                                '${newGroup?.totalTayo ?? 0} طايو',
                                style: TextStyles.getSize16(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),
                        // Show total points only for "مخدوم" user type
                        userType == "مخدوم"
                            ? Container(
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
                                    Icon(
                                      Icons.stars,
                                      color: AppColors.whiteColor,
                                      size: 16,
                                    ),
                                    const Gap(6),
                                    Text(
                                      '$totalPoints  نقاط',
                                      style: TextStyles.getSize16(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // ── Group points card ───────────────────────────────
              GestureDetector(
                onTap: () {
                  log(
                    'Navigating to GroupPointsScreen with group: ${newGroup?.name}, ID: ${newGroup?.gid}',
                  );
                  userType == "مخدوم"
                      ? null
                      : pushTo(
                          context,
                          Routes.groupPointsScreen,
                          extra: newGroup,
                        ).then((newPoints) {
                          cubit.teachersGroupDetails(newGroup);
                          log(
                            'Returned from GroupPointsScreen with new points: $newPoints',
                          );
                          if (newPoints != null && newPoints is int) {
                            setState(() {
                              totalPoints = newPoints;
                            });
                          }
                        });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 14, 20, 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: icon + title + points, all in one compact line
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                pushTo(
                                  context,
                                  Routes.tayoHistoryScreen,
                                  extra: newGroup?.gid,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.stars_rounded,
                                  color: AppColors.primaryColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                'نقاط المجموعة',
                                style: TextStyles.getSize18(
                                  color: AppColors.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$totalPoints',
                                  style: TextStyles.getSize30(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'نقطة',
                                  style: TextStyles.getSize12(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap(5),

                                userType == "خادم"
                                    ? Gap(20)
                                    : Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.primaryColor
                                            .withValues(alpha: 0.7),
                                        size: 25,
                                      ),
                              ],
                            ),
                          ],
                        ),

                        // const Gap(12),
                      ],
                    ),
                  ),
                ),
              ),

              const Gap(16),

              // ── Student grid ───────────────────────────────────
              Expanded(
                child: (students?.isEmpty ?? true) && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_off_rounded,
                              size: 64,
                              color: AppColors.accentColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            const Gap(12),
                            Text(
                              'لم يتم تعيينك في مجموعة بعد',
                              style: TextStyles.getSize18(
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : students?.length != null
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: students?.length ?? 0,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.1,
                            ),
                        itemBuilder: (context, index) {
                          final student = students?[index];
                          return GestureDetector(
                            onTap: () {
                              userType == "مخدوم"
                                  ? null
                                  : pushTo(
                                      context,
                                      Routes.tayoDetailsScreen,
                                      extra: student,
                                    ).then((_) {
                                      // Refresh the group details after returning from the Tayo Details screen
                                      cubit.fetchAndUpdateTotalTayo(
                                        widget.group,
                                      );
                                    });
                            },
                            child: groupStudentCardBuilder(
                              student: student ?? StudentModel(),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
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

class groupStudentCardBuilder extends StatelessWidget {
  const groupStudentCardBuilder({super.key, required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
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
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
            child: ClipOval(
              child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: student.avatarUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
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
          if ((student.studyLevel ?? '').isNotEmpty) ...[
            const Gap(2),
            Text(
              student.studyLevel!,
              style: TextStyles.getSize12(
                color: AppColors.accentColor.withValues(alpha: 0.5),
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
  }
}
