import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

// Remove common elements from two lists
void removeCommonElements(
  List<String> tayoNewCategories,
  List<String> tayoRemovedCategories,
) {
  final set1 = tayoNewCategories.toSet();
  final set2 = tayoRemovedCategories.toSet();
  final common = set1.intersection(set2);
  tayoNewCategories.removeWhere((item) => common.contains(item));
  tayoRemovedCategories.removeWhere((item) => common.contains(item));
}

// Normalise tayo data
Map<String, dynamic> normaliseTayo(Map<String, dynamic> tayo) {
  final normalised = <String, dynamic>{};
  tayo.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final cat = Map<String, dynamic>.from(value);
      if (cat['takenAt'] is Timestamp) {
        cat['takenAt'] = (cat['takenAt'] as Timestamp).millisecondsSinceEpoch;
      }
      normalised[key] = cat;
    } else {
      normalised[key] = value;
    }
  });
  return normalised;
}

class TayoDetailsScreen extends StatefulWidget {
  const TayoDetailsScreen({super.key, required this.student});
  final StudentModel student;

  @override
  State<TayoDetailsScreen> createState() => _TayoDetailsScreenState();
}

class _TayoDetailsScreenState extends State<TayoDetailsScreen> {
  Map<String, dynamic> tayo = {};
  Map<String, dynamic> oldTayo = {};
  List<String> tayoNewCategories = [];
  List<String> tayoRemovedCategories = [];
  final tayoCategoryController = TextEditingController();
  final equality = DeepCollectionEquality();

  int changedTotalTayo = 0;
  int confirmedTotalTayo = 0; // ← add here

  // Check and reset expired tayo items
  void checkAndResetTayo() {
    bool changed = false;
    tayo.forEach((key, value) {
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
      oldTayo = Map<String, dynamic>.from(
        // ← sync oldTayo here
        tayo.map(
          (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
        ),
      );
      log('Expired tayo items reset. Updating student data in Firebase.');
      log('changed total tayo: $changedTotalTayo');
      context.read<HomeCubit>().updateStudentTakenAt(
        widget.student.copyWith(
          tayo: tayo,
          totalTayo: (widget.student.totalTayo ?? 0) + changedTotalTayo,
        ),
      );
    }
  }

  // Check if a takenAt timestamp is expired (10 hours)
  bool isTakenExpired(int? takenAtMillis, {int expireHours = 10}) {
    if (takenAtMillis == null) return true;
    final now = DateTime.now();
    final takenTime = DateTime.fromMillisecondsSinceEpoch(takenAtMillis);
    return now.difference(takenTime).inHours >= expireHours;
  }

  // Save and pop function
  Future<void> saveAndPop({
    required BuildContext context,
    required HomeCubit cubit,
  }) async {
    removeCommonElements(tayoNewCategories, tayoRemovedCategories);
    await cubit.updateStudent(
      newStudent: widget.student.copyWith(
        tayo: tayo,
        totalTayo: (widget.student.totalTayo ?? 0) + changedTotalTayo,
      ),
      oldStudent: widget.student,
      tayoNewCategories: tayoNewCategories,
      tayoRemovedCategories: tayoRemovedCategories,
      groupID: widget.student.groupID,
      groupPointsDelta: changedTotalTayo,
    );
    log('Navigating back to main screen after saving tayo details.');
    // pushToBase(context, Routes.mainScreen, extra: 'خادم');
  }

  @override
  void initState() {
    super.initState();
    confirmedTotalTayo = widget.student.totalTayo ?? 0;
    context.read<HomeCubit>().getStudentTayoDetails(widget.student);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return PopScope(
      canPop: false, // always block, handle manually
      onPopInvokedWithResult: (didPop, result) async {
        //   log('Back navigation triggered. didPop: $didPop, result: $result');
        if (didPop) return;
        if (equality.equals(tayo, oldTayo)) {
          pop(context); // no changes, pop manually
        } else {
          log('Unsaved changes detected. Showing confirmation dialog.');
          log('Current tayo: $tayo');
          log('Old tayo: $oldTayo');
          log('tayo == oldTayo: ${equality.equals(tayo, oldTayo)}');
          log('Changed total tayo: $changedTotalTayo');
          await showChangesNotSavedDialog(
            context,
            tayo: tayo,
            oldTayo: oldTayo,
            mainButtonOnConfirm: () {
              saveAndPop(context: context, cubit: cubit);
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
                    onPressed: () => addNewTayoItemBottomSheet(context),
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
                          if (equality.equals(tayo, oldTayo)) {
                            pop(context); // no changes, pop manually
                          } else {
                            await showChangesNotSavedDialog(
                              context,
                              tayo: tayo,
                              oldTayo: oldTayo,
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
                          widget.student.name ?? 'معلومات المخدوم',
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
                  // Total tayo summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.darkYellowIconColor,
                          size: 28,
                        ),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مجموع الطايو',
                              style: TextStyles.getSize12(
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            Text(
                              '${confirmedTotalTayo + changedTotalTayo}',
                              style: TextStyles.getSize24(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w800,
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

            // ── Tayo list ───────────────────────────────────────────
            Expanded(
              child: BlocConsumer<HomeCubit, HomeState>(
                listener: (context, state) {
                  if (state is HomeLoadingState) {
                    showLoadingDialog(context);
                  } else if (state is HomeErrorState) {
                    pop(context);
                    showMyDialoge(
                      context,
                      state.message,
                      type: DialogType.error,
                    );
                  } else if (state is HomeSuccessState) {
                    pop(context);
                    showMyDialoge(
                      context,
                      state.message ?? " تم تحديث بيانات المخدوم بنجاح.",
                      type: DialogType.success,
                    );
                    pop(context);
                  } else if (state is HomeSuccessStateForTakenAt) {
                    log('HomeSuccessStateForTakenAt triggered');
                  } else if (state is HomeTayoLoadSuccessState) {
                    tayo = normaliseTayo(state.tayo);
                    oldTayo = normaliseTayo(state.tayo);
                    // Compute actual total from fetched tayo
                    int computedTotal = 0;
                    tayo.forEach((key, value) {
                      computedTotal += value['count'] as int? ?? 0;
                    });

                    // Now compare against what Firestore has for totalTayo
                    if (computedTotal != widget.student.totalTayo) {
                      log(
                        '⚠️⚠️⚠️⚠️⚠️Discrepancy detected! computed: $computedTotal, stored: ${widget.student.totalTayo}',
                      );
                      log('Student name: ${widget.student.name}');
                    }

                    checkAndResetTayo();
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (state is HomeErrorState) {
                    return Center(child: Text('حدث خطأ: ${state.message}'));
                  } else if (state is HomeLoadingState && tayo.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }

                  return tayo.isEmpty
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
                          itemCount: tayo.length,
                          separatorBuilder: (_, _) => const Gap(10),
                          itemBuilder: (context, index) {
                            final key = tayo.keys.toList()[index];
                            int categoryvalue = tayo[key]['count'];
                            final takenAt = tayo[key]['takenAt'];
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
                                            tayo.remove(key);
                                            tayoRemovedCategories.add(key);
                                            log(
                                              'removed: ${tayoRemovedCategories.toList()}',
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
                                                  changedTotalTayo++;
                                                  tayo[key] = {
                                                    "count": categoryvalue + 1,
                                                    "takenAt": DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                  };
                                                  log(
                                                    'Updated $key count to ${tayo[key]['count']} with takenAt ${tayo[key]['takenAt']}',
                                                  );
                                                  log(
                                                    'Current tayo state: $tayo',
                                                  );
                                                  log(
                                                    'Current oldTayo state: $oldTayo',
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
                                                    changedTotalTayo--;
                                                    log(
                                                      'Decrementing category: $key, new count will be ${categoryvalue - 1}',
                                                    );
                                                    log(
                                                      'Changed total tayo after decrement: $changedTotalTayo',
                                                    );
                                                    tayo[key] = {
                                                      "takenAt": null,
                                                      "count":
                                                          categoryvalue - 1,
                                                    };
                                                    log(
                                                      'Updated $key count to ${tayo[key]['count']} with takenAt ${tayo[key]['takenAt']}',
                                                    );
                                                    log(
                                                      'Current tayo state: $tayo',
                                                    );
                                                    log(
                                                      'Current oldTayo state: $oldTayo',
                                                    );
                                                    log(
                                                      'tayo == oldTayo: ${equality.equals(tayo, oldTayo)}',
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

  void addNewTayoItemBottomSheet(BuildContext context) {
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
                    controller: tayoCategoryController,
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
                        tayo[tayoCategoryController.text] = {
                          "count": 0,
                          "takenAt": null,
                        };
                        tayoNewCategories.add(tayoCategoryController.text);
                        log('new categories: ${tayoNewCategories.toList()}');
                        tayoCategoryController.clear();
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

class CounterButton extends StatelessWidget {
  const CounterButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.whiteColor, size: 18),
      ),
    );
  }
}
