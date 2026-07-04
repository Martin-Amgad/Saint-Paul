import 'dart:developer';

import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

class GroupsRepo {
  static Future<List<GroupModel>> fetchGroups() async {
    try {
      final snapshot = await FirebaseProvider.fetchGroupsByTotalPoints();

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

  static Future<List<StudentModel>> fetchStudents() async {
    try {
      final snapshot = await FirebaseProvider.getAllStudents();

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
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  }) async {
    try {
      log('Updating group with ID: ${group.gid}');
      log('New Point Categories: $pointNewCategories');
      log('Removed Point Categories: $pointRemovedCategories');
      // THEN update all documents with additions/removals
      if ((pointNewCategories?.isEmpty ?? true) &&
          (pointRemovedCategories?.isEmpty ?? true)) {
        await FirebaseProvider.updateGroup(group);
        return 'تم تحديث بيانات المجموعة بنجاح.';
      }
      await FirebaseProvider.updatePointsInAllGroups(
        pointNewCategories,
        pointRemovedCategories,
      );
      await FirebaseProvider.updateGroup(group);
      pointNewCategories = [];
      pointRemovedCategories = [];

      return 'تم تحديث بيانات المجموعة بنجاح.';
    } on Exception catch (e) {
      throw Exception('Failed to update group: ${e.toString()}');
    } catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المجموعة. الرجاء المحاولة مرة أخرى.';
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
}
