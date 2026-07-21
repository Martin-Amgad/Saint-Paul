import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/teacher_model.dart'; // Make sure this exists
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';

class TeacherInfoEditbuilder extends StatefulWidget {
  const TeacherInfoEditbuilder({
    super.key,
    required this.searchNotifier,
    required this.selectedFamily,
    // No need for selectedYear for teachers; you can remove it or keep it unused.
  });

  final ValueNotifier<String> searchNotifier;
  final String? selectedFamily;

  @override
  State<TeacherInfoEditbuilder> createState() => _TeacherInfoEditbuilderState();
}

class _TeacherInfoEditbuilderState extends State<TeacherInfoEditbuilder> {
  List<TeacherModel> allTeachers = [];
  List<TeacherModel> filteredTeachers = [];
  late Stream<QuerySnapshot> teachersStream;

  @override
  void initState() {
    super.initState();
    // Always fetch teachers for the current church (or adapt if needed)
    teachersStream = FirebaseProvider.streamedSortTeachers(
      LocalHelper.getUserChurchName(),
    );
    log('Initialized teachersStream: $teachersStream');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: teachersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // or a loading indicator
        }

        if (snapshot.hasError) {
          log('teachersStream error: ${snapshot.error}');
          return Center(
            child: Text(
              'حدث خطأ في تحميل الخدام',
              style: TextStyles.getSize18(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        allTeachers = docs
            .map(
              (doc) => TeacherModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();

        filteredTeachers = allTeachers;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder(
            valueListenable: widget.searchNotifier,
            builder: (context, searchText, _) {
              // Apply both search and family filters
              filteredTeachers = allTeachers.where((teacher) {
                final nameMatch =
                    searchText.isEmpty ||
                    (teacher.name ?? '').contains(searchText);
                final familyMatch =
                    widget.selectedFamily == null ||
                    widget.selectedFamily == 'الكل' ||
                    teacher.assignedFamily == widget.selectedFamily;
                return nameMatch && familyMatch;
              }).toList();

              if (filteredTeachers.isEmpty) {
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
                        'لا يوجد خدام',
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
                itemCount: filteredTeachers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final teacher = filteredTeachers[index];

                  return GestureDetector(
                    onLongPress: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      await showChangesNotSavedDialog(
                        context,
                        title: 'هل أنت متأكد؟',
                        content:
                            'سيتم حذف الخادم نهائيا ولن تتمكن من استرجاعه مرة أخرى.',
                        mainButtonText: 'حذف',
                        mainButtonOnConfirm: () {
                          // Assuming ProfileCubit has deleteTeacher
                          context.read<ProfileCubit>().deleteTeacher(
                            teacher.uid!,
                          );
                          pop(context);
                        },
                        secondaryButtonText: 'إلغاء',
                      );
                    },
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      pushTo(
                        context,
                        Routes
                            .editTeachersInfoScreen, // make sure this route exists
                        extra: teacher,
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
                      // child: SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Teacher avatar
                          // CircleAvatar(
                          //   radius: 40,
                          //   backgroundColor: AppColors.primaryColor
                          //       .withValues(alpha: 0.08),
                          //   child: ClipOval(
                          //     child:
                          //         teacher.avatarUrl != null &&
                          //             teacher.avatarUrl!.isNotEmpty
                          //         ? CachedNetworkImage(
                          //             imageUrl: teacher.avatarUrl!,
                          //             width: 70,
                          //             height: 70,
                          //             fit: BoxFit.cover,
                          //             errorWidget: (context, url, error) {
                          //               return const Icon(
                          //                 Icons.person_rounded,
                          //                 color: AppColors.primaryColor,
                          //                 size: 30,
                          //               );
                          //             },
                          //           )
                          //         : const Icon(
                          //             Icons.person_rounded,
                          //             color: AppColors.primaryColor,
                          //             size: 30,
                          //           ),
                          //   ),
                          // ),
                          // Teacher name
                          Text(
                            teacher.name ?? 'بدون اسم',
                            style: TextStyles.getSize16(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Optional: show church/family or "خادم"
                          Gap(2),

                          Text(
                            teacher.role ?? 'خادم',
                            style: TextStyles.getSize12(
                              color: AppColors.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          Gap(2),

                          Text(
                            teacher.assignedFamily ?? 'خادم',
                            style: TextStyles.getSize12(
                              color: AppColors.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ),
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
