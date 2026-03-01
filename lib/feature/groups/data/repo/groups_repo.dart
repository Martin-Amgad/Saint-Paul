import 'dart:developer';

import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';

class GroupsRepo {
  static Future<List<GroupModel>> fetchGroups() async {
    try {
      final snapshot = await FirebaseProvider.fetchGroupsByTotalTayo();

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

  static Future<void> updateGroup(GroupModel group) async {
    try {
      await FirebaseProvider.updateGroup(group);
      log('Group ${group.gid} updated successfully');
    } on Exception catch (e) {
      log('Error updating group ${group.gid}: ${e.toString()}');
      rethrow;
    }
  }
}
