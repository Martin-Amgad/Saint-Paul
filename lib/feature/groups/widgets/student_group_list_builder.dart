import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class StudentGroupListBuilder extends StatelessWidget {
  const StudentGroupListBuilder({
    super.key,
    required this.searchNotifier,
    required this.students,
    required this.selectedStudentIds,
    required this.onStudentToggled,
    this.selectedYear,
    this.isStudent,
  });

  final List<StudentModel>? students;
  final List<String> selectedStudentIds;
  final ValueNotifier<String> searchNotifier;
  final String? selectedYear;
  final bool? isStudent;
  final void Function(String studentId, int totalTayo) onStudentToggled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchNotifier,
      builder: (context, searchText, _) {
        final filtered = students?.where((student) {
          final name = student.name ?? '';
          final studyLevel = student.studyLevel ?? '';
          final matchesSearch = searchText.isEmpty || name.contains(searchText);
          final matchesYear =
              selectedYear == null || studyLevel.contains(selectedYear!);
          return matchesSearch && matchesYear;
        }).toList();

        if (filtered == null || filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.accentColor.withValues(alpha: 0.2),
                ),
                const Gap(12),
                Text(
                  'لا يوجد مخدومون',
                  style: TextStyles.getSize18(
                    color: AppColors.accentColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final student = filtered[index];
            final isSelected = selectedStudentIds.contains(student.uid);

            return GestureDetector(
              onTap: () =>
                  onStudentToggled(student.uid ?? '', student.totalTayo ?? 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withValues(alpha: 0.12)
                      : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors.primaryColor.withValues(
                            alpha: 0.08,
                          ),
                          child: ClipOval(
                            child:
                                student.avatarUrl != null &&
                                    student.avatarUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: student.avatarUrl ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Icon(
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
                        if (isSelected)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.whiteColor,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(6),
                    Text(
                      student.name ?? 'بدون اسم',
                      style: TextStyles.getSize18(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.accentColor,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
