import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';
import 'package:saint_paul/feature/profile/widgets/selectable_student_grid_builder.dart';

class EditTeacherStudentsScreen extends StatefulWidget {
  final TeacherModel teacher;
  const EditTeacherStudentsScreen({super.key, required this.teacher});

  @override
  State<EditTeacherStudentsScreen> createState() =>
      _EditTeacherStudentsScreenState();
}

class _EditTeacherStudentsScreenState extends State<EditTeacherStudentsScreen> {
  final searchController = TextEditingController();
  final ValueNotifier<String> searchNotifier = ValueNotifier('');
  String selectedYearFilter = 'الكل';
  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];
  List<String> selectedIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedIds = List<String>.from(widget.teacher.assignedStudentIds ?? []);
    fetchStudents();
    searchController.addListener(() {
      searchNotifier.value = searchController.text.trim();
      applyFilters();
    });
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final church = LocalHelper.getUserChurchName() ?? '';
      final family = widget.teacher.assignedFamily ?? '';
      final studyLevel = widget.teacher.assignedStudyLevel ?? '';
      allStudents =
          await FirebaseProvider.fetchStudentsByChurchFamilyStudyLevel(
            church: church,
            family: family,
            studyLevel: studyLevel,
          );
      applyFilters();
    } catch (e) {
      log('Error fetching students: $e');
    }
    setState(() => isLoading = false);
  }

  void applyFilters() {
    final searchText = searchNotifier.value;
    filteredStudents = allStudents.where((s) {
      final nameMatch = s.name?.contains(searchText) ?? true;
      final yearMatch =
          selectedYearFilter == 'الكل' || s.studyLevel == selectedYearFilter;
      return nameMatch && yearMatch;
    }).toList();
    setState(() {});
  }

  void toggle(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    final previousIds = List<String>.from(
      widget.teacher.assignedStudentIds ?? [],
    );
    context.read<ProfileCubit>().saveTeacherStudents(
      teacherId: widget.teacher.uid!,
      selectedIds: selectedIds,
      previousIds: previousIds,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final family = widget.teacher.assignedFamily ?? '';
    final studyYears = SchoolYearsModel.allYears[family] ?? [];
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadingState) {
          showLoadingDialog(context);
        } else if (state is ProfileSuccessState) {
          pop(context); // dismiss loading dialog
          pop(context, selectedIds); // pop this screen, return selected IDs
        } else if (state is ProfileErrorState) {
          pop(context); // dismiss loading dialog
          showMyDialoge(context, state.message, type: DialogType.error);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: MainButton(title: 'حفظ', onPressed: _save),
        ),
        body: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
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
              child: Row(
                children: [
                  CustomBackButton(),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل بيانات الخادم',
                        style: TextStyles.getSize24(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SelectableStudentGridBuilder(
                      students: allStudents,
                      selectedIds: selectedIds,
                      onStudentToggled: (id) {
                        setState(() {
                          if (selectedIds.contains(id)) {
                            selectedIds.remove(id);
                          } else {
                            selectedIds.add(id);
                          }
                        });
                      },
                      yearOptions: studyYears,
                      showSearch: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
