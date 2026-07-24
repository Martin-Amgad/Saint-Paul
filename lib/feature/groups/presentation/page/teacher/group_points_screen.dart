import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/tayo_details_screen.dart';
import 'package:collection/collection.dart';

const equality = DeepCollectionEquality();

class GroupPointsScreen extends StatefulWidget {
  const GroupPointsScreen({super.key, this.group});

  final GroupModel? group;

  @override
  State<GroupPointsScreen> createState() => _GroupPointsScreenState();
}

class _GroupPointsScreenState extends State<GroupPointsScreen> {
  Map<String, dynamic> point = {};
  Map<String, dynamic> oldPoint = {};
  List<String> pointNewCategories = [];
  List<String> pointRemovedCategories = [];
  final pointCategoryController = TextEditingController();

  int changedTotalPoint = 0;
  int confirmedTotalPoint = 0; // ← add here

  void checkAndResetPoint() {
    bool changed = false;
    point.forEach((key, value) {
      if (value is Map && value["takenAt"] != null) {
        final takenAt = value["takenAt"];
        final takenAtMillis = takenAt is int
            ? takenAt
            : int.tryParse(takenAt.toString());
        if (takenAtMillis != null && isTakenExpired(takenAtMillis)) {
          value["takenAt"] = null;
          changed = true;
        }
      }
    });
    if (changed) {
      oldPoint = Map<String, dynamic>.from(
        // ← sync oldPoint here
        point.map(
          (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
        ),
      );
      context.read<GroupCubit>().updateGroupTakenAt(
        widget.group!.copyWith(
          points: point,
          totalPoints: (confirmedTotalPoint) + changedTotalPoint,
        ),
      );
    }
  }

  bool isTakenExpired(int? takenAtMillis, {int expireHours = 10}) {
    if (takenAtMillis == null) return true;
    final now = DateTime.now();
    final takenTime = DateTime.fromMillisecondsSinceEpoch(takenAtMillis);
    return now.difference(takenTime).inHours >= expireHours;
  }

  Future<void> saveAndPop({
    required BuildContext context,
    required GroupCubit cubit,
  }) async {
    removeCommonElements(pointNewCategories, pointRemovedCategories);
    log(
      'Saving changes. New categories: $pointNewCategories, Removed categories: $pointRemovedCategories',
    );
    await context.read<GroupCubit>().updateGroup(
      widget.group!.copyWith(
        points: point,
        totalPoints: (confirmedTotalPoint) + changedTotalPoint,
      ),
      oldPoints: oldPoint,
      pointNewCategories: pointNewCategories,
      pointRemovedCategories: pointRemovedCategories,
    );

    setState(() {
      confirmedTotalPoint += changedTotalPoint;
      changedTotalPoint = 0; // reset after update
    });
    // pop(context, confirmedTotalPoint + changedTotalPoint);
  }

  @override
  void initState() {
    super.initState();
    log("its showtime bitches");
    confirmedTotalPoint = widget.group?.totalPoints ?? 0;
    log("1 after showtime bitches");
    log("the show's confirmedTotalPoint is $confirmedTotalPoint");
    if (widget.group != null) {
      context.read<GroupCubit>().getGroupPointsDetails(
        widget.group ?? GroupModel(),
      );
    }

    log("did we succeed papa?");
    log("yes my son");
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupCubit>();
    return PopScope(
      canPop: false, // always block, handle manually
      onPopInvokedWithResult: (didPop, result) async {
        log('Back navigation triggered. didPop: $didPop, result: $result');
        if (didPop) return;
        if (equality.equals(point, oldPoint)) {
          pop(context); // no changes, pop manually
        } else {
          log('Unsaved changes detected. Showing confirmation dialog.');
          log('Current Point: $point');
          log('Old Point: $oldPoint');
          log('Point == oldPoint: ${equality.equals(point, oldPoint)}');
          log('Changed total Point: $changedTotalPoint');
          await showChangesNotSavedDialog(
            context,
            tayo: point,
            oldTayo: oldPoint,
            mainButtonOnConfirm: () {
              log('User confirmed to save changes. Updating student data.');
              log(
                'Updating student with Point: $point, changes to total Point: $changedTotalPoint',
              );
              saveAndPop(context: context, cubit: cubit);
              // pushToBase(context, Routes.mainScreen, extra: 'خادم');
            },
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backgroundColor,
        // ── Bottom bar ───────────────────────────────────────────────────
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: MainButton(
                    title: 'اضف بند جديد',
                    onPressed: () => addNewPointItemBottomSheet(context),
                    bgcolor: AppColors.secondaryColor.withValues(alpha: 0.15),
                    textColor: AppColors.primaryColor,
                    borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: MainButton(
                    title: 'تاكيد',
                    onPressed: () {
                      checkAndResetPoint();
                      saveAndPop(context: context, cubit: cubit);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        body: Column(
          children: [
            // ── Header (extends behind status bar) ─────────────────
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
                  // Back + title
                  Row(
                    children: [
                      CustomButton(
                        onTap: () async {
                          if (equality.equals(point, oldPoint)) {
                            pop(
                              context,
                              confirmedTotalPoint + changedTotalPoint,
                            ); // no changes, pop manually
                          } else {
                            await showChangesNotSavedDialog(
                              context,
                              tayo: point,
                              oldTayo: oldPoint,
                              mainButtonOnConfirm: () {
                                saveAndPop(context: context, cubit: cubit);
                              },
                            );
                          }
                        },
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          widget.group!.name ?? 'معلومات المجموعة',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  // Total Point summary card
                  GestureDetector(
                    onTap: () {
                      pushTo(
                        context,
                        Routes.tayoHistoryScreen,
                        extra: widget.group?.gid,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppColors.darkYellowIconColor,
                            size: 28,
                          ),
                          const Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مجموع النقاط',
                                style: TextStyles.getSize12(
                                  color: AppColors.whiteColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              Text(
                                '${(confirmedTotalPoint) + changedTotalPoint}',
                                style: TextStyles.getSize24(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),

                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.whiteColor.withValues(alpha: 0.7),
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Point list ───────────────────────────────────────────
            Expanded(
              child: BlocConsumer<GroupCubit, GroupState>(
                listener: (context, state) {
                  if (state is GroupLoadingState) {
                    showLoadingDialog(context);
                  } else if (state is GroupErrorState) {
                    pop(context);
                    showMyDialoge(
                      context,
                      state.message,
                      type: DialogType.error,
                    );
                  } else if (state is GroupSuccessState) {
                    pop(context);
                    showMyDialoge(
                      context,
                      'تم تحديث بيانات المخدوم بنجاح',
                      type: DialogType.success,
                    );
                    pop(context, confirmedTotalPoint + changedTotalPoint);
                  } else if (state is GroupSuccessStateForTakenAt) {
                    log('GroupSuccessStateForTakenAt triggered');
                  } else if (state is GroupPointsLoadSuccessState) {
                    point = normaliseTayo(state.point);
                    oldPoint = normaliseTayo(state.point);
                    // Compute actual total from fetched Point
                    int computedTotal = 0;
                    point.forEach((key, value) {
                      computedTotal += value['count'] as int? ?? 0;
                    });

                    // Now compare against what Firestore has for totalPoint
                    if (computedTotal != confirmedTotalPoint) {
                      log(
                        '⚠️⚠️⚠️⚠️⚠️Discrepancy detected! computed: $computedTotal, stored: $confirmedTotalPoint',
                      );
                      log('Group name: ${widget.group!.name}');
                    }

                    checkAndResetPoint();
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (state is GroupErrorState) {
                    return Center(child: Text('حدث خطأ: ${state.message}'));
                  } else if (state is GroupLoadingState && point.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }

                  return point.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 64,
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'لا توجد بنود بعد',
                                style: TextStyles.getSize16(
                                  color: AppColors.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          itemCount: point.length,
                          separatorBuilder: (_, _) => const Gap(10),
                          itemBuilder: (context, index) {
                            final key = point.keys.toList()[index];
                            int categoryvalue = point[key]['count'];
                            final takenAt = point[key]['takenAt'];
                            final isExpired = isTakenExpired(
                              takenAt is int ? takenAt : null,
                            );

                            return Container(
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? AppColors.surfaceColor
                                    : const Color(
                                        0xFF22C55E,
                                      ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isExpired
                                      ? AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        )
                                      : const Color(
                                          0xFF22C55E,
                                        ).withValues(alpha: 0.4),
                                  width: isExpired ? 1 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isExpired
                                        ? Colors.black.withValues(alpha: 0.04)
                                        : const Color(
                                            0xFF22C55E,
                                          ).withValues(alpha: 0.1),
                                    blurRadius: isExpired ? 5 : 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 8, 10),
                                child: Column(
                                  children: [
                                    // Active indicator dot
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isExpired
                                                ? AppColors.accentColor
                                                      .withValues(alpha: 0.2)
                                                : const Color(0xFF22C55E),
                                          ),
                                        ),
                                        const Gap(10),
                                        // Category name
                                        Expanded(
                                          child: Text(
                                            key,
                                            style: TextStyles.getSize18(
                                              color: AppColors.accentColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        // Remove button
                                        IconButton(
                                          onPressed: () {
                                            log('Removing category: $key');
                                            point.remove(key);
                                            pointRemovedCategories.add(key);
                                            log(
                                              'removed: ${pointRemovedCategories.toList()}',
                                            );
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: AppColors.accentColor
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Counter controls
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Increment
                                              CounterButton(
                                                icon: Icons.add_rounded,
                                                onTap: () {
                                                  changedTotalPoint++;
                                                  point[key] = {
                                                    "count": categoryvalue + 1,
                                                    "takenAt": DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                  };
                                                  log(
                                                    'Updated $key count to ${point[key]['count']} with takenAt ${point[key]['takenAt']}',
                                                  );
                                                  log(
                                                    'Current Point state: $point',
                                                  );
                                                  log(
                                                    'Current oldPoint state: $oldPoint',
                                                  );
                                                  setState(() {});
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  '$categoryvalue',
                                                  style: TextStyles.getSize18(
                                                    color:
                                                        AppColors.accentColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // Decrement
                                              CounterButton(
                                                icon: Icons.remove_rounded,
                                                onTap: () {
                                                  if (categoryvalue > 0) {
                                                    changedTotalPoint--;
                                                    log(
                                                      'Decrementing category: $key, new count will be ${categoryvalue - 1}',
                                                    );
                                                    log(
                                                      'Changed total Point after decrement: $changedTotalPoint',
                                                    );
                                                    point[key] = {
                                                      "takenAt": null,
                                                      "count":
                                                          categoryvalue - 1,
                                                    };
                                                    log(
                                                      'Updated $key count to ${point[key]['count']} with takenAt ${point[key]['takenAt']}',
                                                    );
                                                    log(
                                                      'Current Point state: $point',
                                                    );
                                                    log(
                                                      'Current oldPoint state: $oldPoint',
                                                    );
                                                    log(
                                                      'Point == oldPoint: ${equality.equals(point, oldPoint)}',
                                                    );
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addNewPointItemBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'بند طايو جديد',
                    style: TextStyles.getSize18(
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(14),
                  TextField(
                    controller: pointCategoryController,
                    decoration: InputDecoration(
                      hintText: 'اسم البند...',
                      filled: true,
                      fillColor: AppColors.primaryColor.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const Gap(16),
                  MainButton(
                    title: 'اضف البند',
                    onPressed: () {
                      setState(() {
                        point[pointCategoryController.text] = {
                          "count": 0,
                          "takenAt": null,
                        };
                        pointNewCategories.add(pointCategoryController.text);
                        log('new categories: ${pointNewCategories.toList()}');
                        pointCategoryController.clear();
                        pop(context);
                      });
                    },
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
