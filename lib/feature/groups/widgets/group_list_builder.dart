import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';

class GroupsListBuilder extends StatefulWidget {
  const GroupsListBuilder({
    super.key,
    required this.groups,
    required this.searchNotifier,
    this.selectedYear,
  });

  final List<GroupModel>? groups;
  final ValueNotifier<String> searchNotifier;
  final String? selectedYear;

  @override
  State<GroupsListBuilder> createState() => _GroupsListBuilderState();
}

class _GroupsListBuilderState extends State<GroupsListBuilder> {
  List<GroupModel>? filteredGroups;

  @override
  void initState() {
    super.initState();

    filteredGroups = widget.groups;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupDeleteSuccessState) {
          showMyDialoge(
            context,
            state.message ?? 'تم حذف المجموعة بنجاح.',
            type: DialogType.success,
          );
          context.read<GroupCubit>().fetchGroups();
        } else if (state is GroupErrorState) {
          showMyDialoge(context, state.message, type: DialogType.error);
        }
      },
      child: ValueListenableBuilder(
        valueListenable: widget.searchNotifier,
        builder: (context, searchText, _) {
          filteredGroups = searchText.isEmpty && widget.selectedYear == null
              ? widget.groups
              : widget.groups?.where((group) {
                  final name = group.name ?? '';
                  final studyLevel = group.studyLevel ?? '';
                  return name.contains(searchText) &&
                      studyLevel.contains(widget.selectedYear ?? '');
                }).toList();

          if (filteredGroups == null || filteredGroups!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: AppColors.accentColor.withValues(alpha: 0.2),
                  ),
                  const Gap(12),
                  Text(
                    'لا توجد مجموعات',
                    style: TextStyles.getSize18(
                      color: AppColors.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filteredGroups?.length ?? 0,
            separatorBuilder: (_, _) => const Gap(12),
            itemBuilder: (context, index) {
              final group = filteredGroups![index];
              return GestureDetector(
                onLongPress: () {
                  sureToDeleteMissionDialog(
                    context,
                    title: 'هل أنت متأكد من حذف المجموعة؟',
                    content: 'سيتم حذف المجموعة ولن تتمكن من استعادتها.',
                    mainButtonText: 'حذف',
                    mainButtonOnConfirm: () {
                      context.read<GroupCubit>().deleteGroup(group);
                      pop(context);
                    },
                    secondaryButtonText: 'إلغاء',
                    secondaryButtonOnConfirm: () => pop(context),
                  );
                },
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  pushTo(context, Routes.groupDetailsScreen, extra: group);
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title row ──────────────────────────
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
                              child: const Icon(
                                Icons.groups_rounded,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                group.name ?? '',
                                style: TextStyles.getSize18(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
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
                        // ── Study level ────────────────────────
                        if ((group.studyLevel ?? '').isNotEmpty)
                          Text(
                            group.studyLevel!,
                            style: TextStyles.getSize16(
                              color: AppColors.accentColor.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        const Gap(12),
                        Divider(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        const Gap(10),
                        // ── Stats row ──────────────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.people_rounded,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                            const Gap(6),
                            Text(
                              'عدد المخدومين: ',
                              style: TextStyles.getSize12(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${group.students?.length ?? 0}',
                              style: TextStyles.getSize16(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.darkYellowIconColor,
                              size: 18,
                            ),
                            const Gap(6),
                            Text(
                              'الطايو: ',
                              style: TextStyles.getSize12(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${group.totalTayo ?? 0}',
                              style: TextStyles.getSize16(
                                color: AppColors.darkYellowIconColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
