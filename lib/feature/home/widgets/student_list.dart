import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class StudentList extends StatelessWidget {
  const StudentList({
    super.key,
    required this.searchText,
    required this.filterSelection,
    this.isStudent = false,
  });

  final String searchText;
  final String filterSelection;
  final bool? isStudent;

  Color? _rankColor(int index) {
    if (index == 0) return AppColors.yellowIconColor;
    if (index == 1) return const Color(0xFFB0B0B0);
    if (index == 2) return const Color(0xFFCD7F32);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<StudentModel> allStudents;
    List<StudentModel> allStudentsWithYear;
    List<StudentModel> filteredStudents;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseProvider.streamedSortStudentsByTotalTayo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }

        if (snapshot.hasError) {
          log('streamedSortStudentsByTotalTayo error: ${snapshot.error}');
          return Center(
            child: Text(
              'حدث خطا في تحميل المخدومين',
              style: TextStyles.getSize18(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        allStudents = docs
            .map(
              (doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();
        allStudentsWithYear = allStudents
            .where(
              (student) => (student.studyLevel ?? '').contains(filterSelection),
            )
            .toList();
        filteredStudents = searchText.isEmpty && filterSelection == 'الكل'
            ? allStudents
            : allStudents.where((student) {
                final name = student.name ?? '';
                final studyLevel = student.studyLevel ?? '';
                final matchesSearch = name.contains(searchText);
                final matchesFilter = filterSelection == 'الكل'
                    ? true
                    : studyLevel.contains(filterSelection);
                return matchesSearch && matchesFilter;
              }).toList();

        if (filteredStudents.isEmpty) {
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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: filteredStudents.length,
          itemBuilder: (context, index) {
            final student = filteredStudents[index];
            final rankColor = _rankColor(index);
            final isTopThree = (rankColor != null) && searchText.isEmpty;
            final isTopFifteen = index < 15 && searchText.isEmpty;
            final tayo = student.totalTayo ?? 0;

            return GestureDetector(
              onTap: () {
                if (isStudent == true) return;
                pushTo(context, Routes.tayoDetailsScreen, extra: student);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isTopThree
                      ? rankColor.withValues(alpha: 0.07)
                      : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isTopThree
                        ? rankColor.withValues(alpha: 0.4)
                        : AppColors.primaryColor.withValues(alpha: 0.1),
                    width: isTopThree ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isTopThree
                          ? rankColor.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isTopThree ? 12 : 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isTopThree
                            ? rankColor.withValues(alpha: 0.15)
                            : AppColors.primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTopThree
                              ? rankColor.withValues(alpha: 0.5)
                              : AppColors.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Center(
                        child: isTopThree
                            ? Icon(
                                Icons.emoji_events_rounded,
                                size: 20,
                                color: rankColor,
                              )
                            : Text(
                                '${allStudentsWithYear.indexOf(filteredStudents[index]) + 1}',
                                style: TextStyles.getSize16(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name ?? 'بدون اسم',
                            style: TextStyles.getSize18(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((student.studyLevel ?? '').isNotEmpty) ...[
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
                        ],
                      ),
                    ),
                    if (tayo > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isTopThree
                              ? rankColor.withValues(alpha: 0.15)
                              : AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$tayo',
                          style: TextStyles.getSize16(
                            color: isTopThree
                                ? rankColor
                                : AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const Gap(6),
                    Icon(
                      isTopThree ? Icons.military_tech : null,
                      size: 20,
                      color: AppColors.accentColor.withValues(alpha: 0.3),
                    ),
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
