import 'dart:developer';

import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class GroupsRepo {
  static Future<List<GroupModel>> fetchGroups() async {
    try {
      String? church = LocalHelper.getUserChurchName();
      final snapshot = await FirebaseProvider.fetchChurchGroupsByTotalPoints(
        churchName: church,
      );

      log('Fetched groups snapshot: ${snapshot.docs.length} documents');
      try {
        final groups = snapshot.docs.map((doc) {
          log('Parsing doc: ${doc.id} → ${doc.data()}');
          return GroupModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        return groups;
      } on Exception catch (e) {
        log('Error sorting groups: ${e.toString()}');
        return [];
      }
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<GroupModel?> fetchGroup(String? groupId) async {
    try {
      final snapshot = await FirebaseProvider.getGroupbyId(groupId);

      try {
        if (snapshot.exists) {
          log('Parsing doc: ${snapshot.id} → ${snapshot.data()}');
          return GroupModel.fromJson(
            snapshot.data() as Map<String, dynamic>,
            snapshot.id,
          );
        }
        return null;
      } on Exception catch (e) {
        log('Error sorting groups: ${e.toString()}');
        return null;
      }
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<List<StudentModel>> fetchStudents(
    String? family,
    String? churchName,
  ) async {
    try {
      final snapshot = await FirebaseProvider.getAllStudents(churchName ?? '');

      log('Fetched students snapshot: ${snapshot.docs.length} documents');
      try {
        final students = snapshot.docs.map((doc) {
          log('Parsing doc: ${doc.id} → ${doc.data()}');
          return StudentModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        return students;
      } on Exception catch (e) {
        log('Error sorting students: ${e.toString()}');
        return [];
      }
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<List<StudentModel>> fetchStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final futures = ids.map((id) => FirebaseProvider.getStudentByID(id));
      final snapshots = await Future.wait(futures);
      return snapshots
          .where((doc) => doc.exists)
          .map(
            (doc) => StudentModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      log('fetchStudentsByIds error: $e');
      rethrow;
    }
  }

  static Future<void> deleteGroup(String groupId) async {
    try {
      await FirebaseProvider.deleteGroup(groupId);
      log('Group $groupId deleted successfully');
    } on Exception catch (e) {
      log('Error deleting group $groupId: ${e.toString()}');
      rethrow;
    }
  }

  static Future<String?> updateGroup(
    GroupModel group, {
    required Map<String, dynamic> oldPoints, // ← new
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  }) async {
    try {
      log(
        'Updating group ${group.gid} with new points: ${group.points}, oldPoints: $oldPoints ',
      );
      // 1. Compute deltas using the same helper
      final deltas = TayoHistoryModel.computeTayoChanges(
        oldTayo: oldPoints,
        newTayo: group.points ?? {},
        removedCategories: pointRemovedCategories ?? [],
      );
      log('Computed deltas for group ${group.gid}: $deltas');

      // 2. Bulk category update if needed (optional)
      if ((pointNewCategories?.isNotEmpty ?? false) ||
          (pointRemovedCategories?.isNotEmpty ?? false)) {
        // If you have a global group categories collection, update it here
        // await FirebaseProvider.updateGroupCategories(...);
      }

      // 3. Get teacher info
      final teacher = LocalHelper.getTeacherData();
      if (teacher == null || teacher.uid == null || teacher.name == null) {
        return 'تعذر الحصول على بيانات المعلم.';
      }

      log(
        'In Repo deltas: $deltas, pointRemovedCategories: $pointRemovedCategories, teacherId: ${teacher.uid}, teacherName: ${teacher.name}',
      );
      // 4. Atomic transaction
      await FirebaseProvider.propagateCategoryChanges(
        currentGroupId: group.gid!,
        newCategories: pointNewCategories ?? [],
        removedCategories: pointRemovedCategories ?? [],
      );

      await FirebaseProvider.updateGroupWithHistory(
        groupId: group.gid!,
        deltas: deltas,
        removedCategories: pointRemovedCategories ?? [],
        teacherId: teacher.uid!,
        teacherName: teacher.name!,
      );

      return 'تم تحديث المجموعة بنجاح.';
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث المجموعة.';
    }
  }

  static Future<void> updateGroupPoints({
    required String groupId,
    required int changeInPoints,
  }) {
    return FirebaseProvider.updateGroupPoints(
      groupId: groupId,
      changeInPoints: changeInPoints,
    );
  }

  static Future<String?> updateGroupTakenAt(GroupModel group) async {
    try {
      await FirebaseProvider.updateGroup(group);
      return 'تم تحديث بيانات المجموعة بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المجموعة. الرجاء المحاولة مرة أخرى.';
    }
  }

  static Future<Map<String, dynamic>?> getGroupPointsDetails(
    GroupModel group,
  ) async {
    try {
      final snapshot = await FirebaseProvider.getGroupByID(group.gid ?? '');

      final data = ((snapshot.data()) as Map<String, dynamic>?) ?? {};

      return data['points'] as Map<String, dynamic>? ?? {};
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<void> updateGroupTotalTayo(
    String groupId,
    int totalTayo,
  ) async {
    await FirebaseProvider.updateGroupTotalTayo(
      groupId: groupId,
      totalTayo: totalTayo,
    );
  }
}
