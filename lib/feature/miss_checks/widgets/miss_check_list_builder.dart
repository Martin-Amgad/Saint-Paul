import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

/// How urgent it is to check a student, based on how close the current
/// church week (Friday → Thursday) is to ending. Nothing to do with when
/// the student was last checked historically — only "is the deadline
/// close".
enum WeekUrgency { calm, warning, critical }

class MissCheckListBuilder extends StatefulWidget {
  const MissCheckListBuilder({super.key, required this.searchNotifier});

  final ValueNotifier<String> searchNotifier;

  @override
  State<MissCheckListBuilder> createState() => _MissCheckListBuilderState();
}

class _MissCheckListBuilderState extends State<MissCheckListBuilder> {
  List<StudentModel> allStudents = [];
  List<StudentModel> dueStudents = [];
  List<String> assignedStudentIds = [];
  bool _assignedLoaded = false;
  late Stream<QuerySnapshot> studentsStream;

  // Optimistically-hidden students (checked off locally, write in flight).
  final Set<String> _justChecked = {};

  @override
  void initState() {
    super.initState();

    studentsStream = FirebaseProvider.streamedSortStudentsByTotalTayo(
      LocalHelper.getUserFamily(),
      LocalHelper.getUserChurchName(),
    );

    FirebaseProvider.getAssignedStudentIdsForTeacher(
      LocalHelper.getUserId() ?? '',
    ).then((ids) {
      if (mounted) {
        setState(() {
          assignedStudentIds = ids;
          _assignedLoaded = true;
        });
      }
    });
  }

  /// Start of the current church week (Friday).
  DateTime _startOfWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Dart: Monday=1 ... Sunday=7. Friday=5.
    final daysSinceFriday = (today.weekday - DateTime.friday + 7) % 7;
    return today.subtract(Duration(days: daysSinceFriday));
  }

  /// Last day of the current church week (Thursday, 6 days after Friday).
  DateTime _endOfWeek() => _startOfWeek().add(const Duration(days: 6));

  bool _isDueThisWeek(StudentModel student) {
    if (student.lastMissCheck == null) return true;
    return student.lastMissCheck!.isBefore(_startOfWeek());
  }

  /// Days left until the week ends (0 = today is the last day, Thursday).
  int _daysLeftInWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _endOfWeek().difference(today).inDays;
  }

  WeekUrgency _weekUrgency() {
    final daysLeft = _daysLeftInWeek();
    if (daysLeft <= 1) return WeekUrgency.critical; // Wed & Thu
    if (daysLeft <= 3) return WeekUrgency.warning; // Mon & Tue
    return WeekUrgency.calm; // Fri, Sat, Sun
  }

  Color _colorFor(WeekUrgency urgency) {
    switch (urgency) {
      case WeekUrgency.critical:
        return const Color(0xFFE5484D); // red
      case WeekUrgency.warning:
        return const Color(0xFFF5A524); // orange
      case WeekUrgency.calm:
        return AppColors.primaryColor;
    }
  }

  String _daysLeftLabel() {
    final daysLeft = _daysLeftInWeek();
    if (daysLeft <= 0) return 'آخر يوم في الأسبوع';
    if (daysLeft == 1) return 'باقي يوم واحد';
    return 'باقي $daysLeft أيام';
  }

  Future<void> _markChecked(StudentModel student) async {
    if (student.uid == null) return;
    setState(() => _justChecked.add(student.uid!));
    try {
      await FirebaseProvider.updateStudentLastMissCheck(student.uid!);
    } catch (e) {
      log('Failed to update lastMissCheck for ${student.uid}: $e');
      if (mounted) {
        setState(() => _justChecked.remove(student.uid!));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ، حاول مرة أخرى')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_assignedLoaded) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: studentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (snapshot.hasError) {
          log('MissCheckListBuilder stream error: ${snapshot.error}');
          return Center(
            child: Text(
              'حدث خطأ في تحميل بيانات الافتقاد',
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

        final urgency = _weekUrgency();
        final urgencyColor = _colorFor(urgency);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder(
            valueListenable: widget.searchNotifier,
            builder: (context, searchText, _) {
              // Teacher's assigned students only, still due this week.
              dueStudents =
                  allStudents.where((student) {
                    if (student.uid == null) return false;
                    if (!assignedStudentIds.contains(student.uid)) return false;
                    if (_justChecked.contains(student.uid)) return false;
                    if (!_isDueThisWeek(student)) return false;

                    final nameMatch =
                        searchText.isEmpty ||
                        (student.name ?? '').contains(searchText);
                    return nameMatch;
                  }).toList()..sort(
                    (a, b) => (a.name ?? '').compareTo(b.name ?? ''),
                  );

              if (dueStudents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: AppColors.accentColor.withValues(alpha: 0.2),
                      ),
                      const Gap(12),
                      Text(
                        'تم الافتقاد على الجميع هذا الأسبوع',
                        style: TextStyles.getSize18(
                          color: AppColors.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  if (urgency != WeekUrgency.calm)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 16,
                            color: urgencyColor,
                          ),
                          const Gap(6),
                          Text(
                            _daysLeftLabel(),
                            style: TextStyles.getSize16(
                              color: urgencyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: dueStudents.length,
                      separatorBuilder: (_, __) => const Gap(10),
                      itemBuilder: (context, index) {
                        final student = dueStudents[index];
                        return _MissCheckTile(
                          student: student,
                          urgency: urgency,
                          color: urgencyColor,
                          onCheck: () => _markChecked(student),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// A single student row. Pulses/glows when [urgency] is critical
/// (week is about to end and this student still isn't checked).
class _MissCheckTile extends StatefulWidget {
  const _MissCheckTile({
    required this.student,
    required this.urgency,
    required this.color,
    required this.onCheck,
  });

  final StudentModel student;
  final WeekUrgency urgency;
  final Color color;
  final VoidCallback onCheck;

  @override
  State<_MissCheckTile> createState() => _MissCheckTileState();
}

class _MissCheckTileState extends State<_MissCheckTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.urgency == WeekUrgency.critical) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final borderColor = widget.color;

    Widget tile = Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
            child: ClipOval(
              child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: student.avatarUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryColor,
                    ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              student.name ?? 'بدون اسم',
              style: TextStyles.getSize16(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(8),
          Checkbox(
            value: false,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (_) => widget.onCheck(),
          ),
        ],
      ),
    );

    if (_controller == null) return tile;

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        final glow = 0.15 + (_controller!.value * 0.35); // 0.15 → 0.5
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: glow),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: tile,
    );
  }
}
