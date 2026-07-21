import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';

class StudentInfoEditbuilder extends StatefulWidget {
  const StudentInfoEditbuilder({
    super.key,
    required this.searchNotifier,
    required this.selectedYear,
  });

  final ValueNotifier<String> searchNotifier;
  final String? selectedYear;

  @override
  State<StudentInfoEditbuilder> createState() => _StudentInfoEditbuilderState();
}

class _StudentInfoEditbuilderState extends State<StudentInfoEditbuilder> {
  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];
  List<String> assignedStudentIds = [];
  late Stream<QuerySnapshot> studentsStream;
  @override
  void initState() {
    super.initState();

    studentsStream = FirebaseProvider.streamedSortStudentsByTotalTayo(
      family: LocalHelper.getUserFamily(),
      church: LocalHelper.getUserChurchName() ?? '',
    );
    FirebaseProvider.getAssignedStudentIdsForTeacher(
      LocalHelper.getUserId() ?? '',
    ).then((ids) {
      if (mounted) {
        setState(() {
          assignedStudentIds = ids;
        });
      }
    });
    log('Assigned student IDs for teacher: $assignedStudentIds');
    log('Initialized studentsStream with stream: $studentsStream');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: studentsStream,
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

        filteredStudents = allStudents;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder(
            valueListenable: widget.searchNotifier,
            builder: (context, searchText, _) {
              log('Assigned student IDs for teacher: $assignedStudentIds');

              final isServant = LocalHelper.getUserType() == 'خادم';
              final teacherStudyLevel = isServant
                  ? (LocalHelper.getUserStudyLevel() ?? '')
                  : '';

              filteredStudents = allStudents.where((student) {
                // 1. Name always must match the search text
                final nameMatch =
                    searchText.isEmpty ||
                    (student.name ?? '').contains(searchText);

                if (isServant) {
                  // 2. Servant: always restrict to the teacher's own study level
                  final yearMatch =
                      (student.studyLevel ?? '') == teacherStudyLevel;

                  // 3. If the chip is 'الكل' → show all students of that level.
                  //    If 'مخدومينى' → show only the teacher's assigned students.
                  final assignedMatch =
                      widget.selectedYear == 'الكل' ||
                      assignedStudentIds.contains(student.uid);

                  return nameMatch && yearMatch && assignedMatch;
                } else {
                  // 4. Non‑servant: use the original year filter (actual school years)
                  final yearFilter = widget.selectedYear;
                  final yearMatch =
                      yearFilter == null ||
                      yearFilter == 'الكل' ||
                      (student.studyLevel ?? '').contains(yearFilter);

                  return nameMatch && yearMatch;
                }
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

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: filteredStudents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];

                  return GestureDetector(
                    onLongPress: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      await showChangesNotSavedDialog(
                        context,
                        title: 'هل أنت متأكد؟',
                        content:
                            'سيتم حذف المخدوم نهائيا ولن تتمكن من استرجاعه مرة أخرى.',
                        mainButtonText: 'حذف',
                        mainButtonOnConfirm: () {
                          ProfileCubit().deleteStudent(student.uid!);
                          pop(context);
                        },
                        secondaryButtonText: 'إلغاء',
                      );
                    },
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      pushTo(
                        context,
                        Routes.addEditNewStudentScreen,
                        extra: student,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,

                        child: Column(
                          children: [
                            // image circular avatar
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryColor
                                  .withValues(alpha: 0.08),
                              child: ClipOval(
                                child:
                                    student.avatarUrl != null &&
                                        student.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: student.avatarUrl ?? '',
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return const Icon(
                                            Icons.person_rounded,
                                            color: AppColors.primaryColor,
                                            size: 30,
                                          );
                                        },
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        color: AppColors.primaryColor,
                                        size: 30,
                                      ),
                              ),
                            ),

                            const Gap(3),
                            // Name & level
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
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
