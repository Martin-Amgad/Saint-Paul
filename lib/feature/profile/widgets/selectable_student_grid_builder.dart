import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/widgets/filter_chip.dart';
import 'package:saint_paul/feature/profile/widgets/student_card.dart';

class SelectableStudentGridBuilder extends StatefulWidget {
  final List<StudentModel> students; // all eligible students
  final List<String> selectedIds; // pre‑selected IDs
  final ValueChanged<String> onStudentToggled;
  final List<String>? yearOptions; // e.g. ['اولي اعدادي', ...]
  final bool showSearch;

  const SelectableStudentGridBuilder({
    super.key,
    required this.students,
    required this.selectedIds,
    required this.onStudentToggled,
    this.yearOptions,
    this.showSearch = true,
  });

  @override
  State<SelectableStudentGridBuilder> createState() =>
      _SelectableStudentGridBuilderState();
}

class _SelectableStudentGridBuilderState
    extends State<SelectableStudentGridBuilder> {
  final searchController = TextEditingController();
  String searchText = '';
  String? selectedYearFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() => searchText = searchController.text.trim());
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get filteredStudents {
    return widget.students.where((s) {
      final nameMatch = s.name?.contains(searchText) ?? true;
      final yearMatch =
          selectedYearFilter == null ||
          selectedYearFilter == 'الكل' ||
          s.studyLevel == selectedYearFilter;
      return nameMatch && yearMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearch) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: searchController,
              hintText: 'بحث عن مخدوم...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryColor,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
            ),
          ),

          const Gap(8),
        ],
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(5, 8, 16, 24),
            itemCount: filteredStudents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
              final isSelected = widget.selectedIds.contains(student.uid);
              return StudentCard(
                student: student,
                isSelected: isSelected,
                onTap: () => widget.onStudentToggled(student.uid!),
              );
            },
          ),
        ),
        if (filteredStudents.isEmpty)
          const Center(child: Text('لا يوجد مخدومين'))
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
