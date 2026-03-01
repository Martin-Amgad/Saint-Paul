import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';
import 'package:saint_paul/feature/groups/widgets/group_list_builder.dart';
import 'package:saint_paul/feature/home/data/lists/1st_prep_students_list.dart';
import 'package:saint_paul/feature/home/data/lists/3rd_prep_students_list.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/home/widgets/student_info_edit_builder.dart';

class GroupsShowcaseScreen extends StatefulWidget {
  const GroupsShowcaseScreen({super.key});

  @override
  State<GroupsShowcaseScreen> createState() => _GroupsShowcaseScreenState();
}

class _GroupsShowcaseScreenState extends State<GroupsShowcaseScreen> {
  var searchController = TextEditingController();
  ValueNotifier<String> searchNotifier = ValueNotifier('');

  String searchText = '';
  String? selectedYear;

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<GroupCubit>().fetchGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.darkYellowIconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'المجموعات',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    HeaderIconButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        pushTo(context, Routes.createGroupScreen).then((_) {
                          context.read<GroupCubit>().fetchGroups();
                        });

                        // var futures = thirdPrepStudentList.map((student) {
                        //   return FirebaseProvider.createStudent(student);
                        // });
                        // Future.wait(futures);
                      },
                    ),
                  ],
                ),
                const Gap(18),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomTextField(
                    controller: searchController,
                    hintText: "بحث عن مخدوم...",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: SvgPicture.asset(
                        AppAssets.searchSvg,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.withValues(alpha: 0.7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchText = '';
                          searchNotifier.value = searchText;
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                    onChanged: (value) {
                      searchText = value.trim();
                      searchNotifier.value = searchText;
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Text(
                  'فلتر:',
                  style: TextStyles.getSize16(
                    color: AppColors.accentColor.withValues(alpha: 0.6),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilteredChip(
                          label: 'الكل',
                          selected: selectedYear == null,
                          onTap: () => setState(() => selectedYear = null),
                        ),
                        const Gap(8),
                        FilteredChip(
                          label: 'اولي اعدادي',
                          selected: selectedYear == 'اولي اعدادي',
                          onTap: () =>
                              setState(() => selectedYear = 'اولي اعدادي'),
                        ),
                        const Gap(8),
                        FilteredChip(
                          label: 'تانيه اعدادي',
                          selected: selectedYear == 'تانيه اعدادي',
                          onTap: () =>
                              setState(() => selectedYear = 'تانيه اعدادي'),
                        ),
                        const Gap(8),
                        FilteredChip(
                          label: 'ثالثة اعدادي',
                          selected: selectedYear == 'ثالثة اعدادي',
                          onTap: () =>
                              setState(() => selectedYear = 'ثالثة اعدادي'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(14),

          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<GroupCubit, GroupState>(
              listener: (context, state) {
                if (state is GroupErrorState) {
                  showMyDialoge(context, state.message, type: DialogType.error);
                } else if (state is GroupDeleteSuccessState) {
                  showMyDialoge(
                    context,
                    state.message ?? 'تم حذف المجموعة بنجاح.',
                    type: DialogType.success,
                  ).then((_) {
                    context.read<GroupCubit>().fetchGroups();
                  });
                }
              },
              builder: (context, state) {
                if (state is GroupLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupsLoadedSuccessState) {
                  return GroupsListBuilder(
                    groups: state.groups,
                    searchNotifier: searchNotifier,
                    selectedYear: selectedYear,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
