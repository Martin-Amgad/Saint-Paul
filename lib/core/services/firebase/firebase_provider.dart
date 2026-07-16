import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class FirebaseProvider {
  static final FirebaseFirestore firebase = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> studentCollection =
      firebase.collection('Student');

  static final CollectionReference<Map<String, dynamic>> teacherCollection =
      firebase.collection('Teacher');

  static final CollectionReference<Map<String, dynamic>> missionCollection =
      firebase.collection('Mission');

  static final CollectionReference<Map<String, dynamic>> groupCollection =
      firebase.collection('Group');

  static final CollectionReference<Map<String, dynamic>> configCollection =
      firebase.collection('config');

  static final CollectionReference<Map<String, dynamic>> badgesCollection =
      firebase.collection('Badges');

  static final CollectionReference<Map<String, dynamic>> fcmTokensCollection =
      firebase.collection('fcmTokens');

  // TEACHER METHODS ////////////////////////////////////////////////////////////
  static Future<void> createTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).set(teacher.toJson());
  }

  static Future<void> updateTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).update(teacher.toUpdateData());
  }

  static Future<TeacherModel?> getTeacherByID(String? id) async {
    if (id == null) return null;
    final doc = await teacherCollection.doc(id).get();
    if (!doc.exists) return null;
    return TeacherModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Stream<QuerySnapshot> streamedSortTeachers(String? church) {
    return teacherCollection.where('church', isEqualTo: church).snapshots();
  }

  static Future<void> deleteTeacher(String teacherId) async {
    await teacherCollection.doc(teacherId).delete();
  }

  static Future<List<StudentModel>> fetchStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Firestore allows max 10 items in `whereIn` – chunk if needed
    final snapshot = await studentCollection
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              StudentModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  static Future<List<StudentModel>> fetchStudentsByChurchFamilyStudyLevel({
    required String church,
    required String family,
    required String studyLevel,
  }) async {
    final snapshot = await studentCollection
        .where('church', isEqualTo: church)
        .where('family', isEqualTo: family)
        .where('studyLevel', isEqualTo: studyLevel)
        .get();

    return snapshot.docs
        .map((doc) => StudentModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Updates the teacher's assignedStudentIds and syncs the responsibleTeacher field on each student.
  /// [addedStudentIds] – students newly assigned to the teacher.
  /// [removedStudentIds] – students removed from the teacher.
  static Future<void> updateTeacherAndStudents({
    required String teacherId,
    required List<String> assignedStudentIds,
    required List<String> addedStudentIds,
    required List<String> removedStudentIds,
  }) async {
    final batch = firebase.batch();

    // Teacher document
    batch.update(teacherCollection.doc(teacherId), {
      'assignedStudentIds': assignedStudentIds,
    });

    // Students that were added → set responsibleTeacher
    for (final id in addedStudentIds) {
      batch.update(studentCollection.doc(id), {
        'responsibleTeacher': teacherId,
      });
    }

    // Students that were removed → clear responsibleTeacher
    for (final id in removedStudentIds) {
      batch.update(studentCollection.doc(id), {
        'responsibleTeacher': '', // or FieldValue.delete()
      });
    }

    await batch.commit();
  }

  static Future<List<String>> getAssignedStudentIdsForTeacher(
    String teacherId,
  ) async {
    try {
      final doc = await teacherCollection.doc(teacherId).get();
      final data = doc
          .data(); // returns Map<String, dynamic>? (null if doc doesn't exist)
      if (data == null) return [];
      log(
        'Fetched assignedStudentIds for teacher $teacherId: ${data['assignedStudentIds']}',
      );
      return (data['assignedStudentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } catch (e) {
      log('Error fetching assigned student IDs: $e');
      return [];
    }
  }

  static Future<void> updateChurchAdminPassword(String newPassword) async {
    try {
      String? churchName = LocalHelper.getUserChurchName();
      await configCollection.doc('defaults').update({
        'churchNames.$churchName': newPassword,
      });
      log('Admin password updated successfully');
    } catch (e) {
      log('Error updating admin password: $e');
    }
  }

  // STUDENT METHODS ////////////////////////////////////////////////////////////
  static Map<String, dynamic> updateTayoMethod(
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  ) {
    Map<String, dynamic> updates = {};

    for (var key in tayoNewCategories ?? []) {
      updates['tayo.$key.count'] = 0;
      updates['tayo.$key.takenAt'] = null;
    }

    for (var key in tayoRemovedCategories ?? []) {
      updates['tayo.$key'] = FieldValue.delete();
    }
    return updates;
  }

  static Future<void> createStudent(StudentModel student) async {
    await studentCollection.doc(student.uid).set(student.toJson());
  }

  static Future<void> updateStudentGroupID(
    String studentId,
    String groupId,
  ) async {
    await studentCollection.doc(studentId).update({'groupID': groupId});
  }

  static Future<QuerySnapshot> getStudentByNameAndTotalTayo(
    String searchKey,
  ) async {
    return await studentCollection
        .orderBy('name')
        .startAt([searchKey])
        .endAt(['$searchKey\uf8ff'])
        .orderBy('totalTayo', descending: true)
        .get();
  }

  static Future<void> updateStudent(StudentModel student) async {
    await studentCollection.doc(student.uid).update(student.toUpdateData());
  }

  static Future<List<StudentModel>> getStudentsByFamily(
    String family,
    String studyLevel,
  ) async {
    try {
      var church = LocalHelper.getUserChurchName();
      final querySnapshot = await studentCollection
          .where('family', isEqualTo: family)
          .where('studyLevel', isEqualTo: studyLevel)
          .where('church', isEqualTo: church)
          .get();

      return querySnapshot.docs
          .map((doc) => StudentModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log(
        'Failed to fetch students for family $family and study level $studyLevel: $e',
      );
      throw Exception('Failed to fetch students: $e');
    }
  }

  /// Atomically applies Tayo deltas and records history.
  static Future<void> updateStudentWithHistory({
    required String studentId,
    required List<TayoHistoryModel> deltas,
    required List<String> removedCategories,
    required String teacherId,
    required String teacherName,
    String? groupID,
    int? groupPointsDelta,
    Map<String, dynamic>? otherFields,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final studentRef = firestore.collection('Student').doc(studentId);
    final historyRef = studentRef.collection('history');
    final groupRef = (groupID != null && groupID.isNotEmpty)
        ? firestore.collection('Group').doc(groupID)
        : null;

    await firestore.runTransaction((transaction) async {
      // 1. Read current server state
      final studentSnap = await transaction.get(studentRef);
      log('🔍 Transaction started. Student exists: ${studentSnap.exists}');
      if (!studentSnap.exists) {
        return;
      }

      final data = studentSnap.data()!;
      log('📦 Server data: $data');

      Map<String, dynamic> tayo = Map<String, dynamic>.from(data['tayo'] ?? {});
      int totalTayo = data['totalTayo'] ?? 0;
      log('📊 Before deltas: tayo=$tayo, totalTayo=$totalTayo');

      // 2. Apply each delta (skipping removed categories)
      for (final delta in deltas) {
        if (removedCategories.contains(delta.category)) continue;

        final existing = tayo[delta.category];
        if (existing != null && existing is Map<String, dynamic>) {
          final currentCount = (existing['count'] as num?)?.toInt() ?? 0;
          existing['count'] = currentCount + (delta.change ?? 0);
          existing['takenAt'] = FieldValue.serverTimestamp();
        } else {
          // Category doesn’t exist yet on server – safe creation
          tayo[delta.category ?? 'غير معروف'] = {
            'count': delta.change ?? 0,
            'takenAt': FieldValue.serverTimestamp(),
          };
        }
        totalTayo += delta.change ?? 0;
      }

      // 3. Handle removed categories (subtract their count, then delete)
      for (final cat in removedCategories) {
        if (tayo.containsKey(cat)) {
          final catData = tayo[cat] as Map<String, dynamic>;
          final count = (catData['count'] as num?)?.toInt() ?? 0;
          totalTayo -= count;
          tayo.remove(cat);
        }
      }

      log('📊 After deltas: tayo=$tayo, totalTayo=$totalTayo');

      // 4. Write the student document
      transaction.update(studentRef, {'tayo': tayo, 'totalTayo': totalTayo});
      log('✍️ Transaction update sent');

      // 5. Write a history document for each delta (again, skip removed)
      for (final delta in deltas) {
        if (removedCategories.contains(delta.category)) continue;
        final historyDoc = historyRef.doc(); // auto‑ID
        transaction.set(historyDoc, {
          'category': delta.category,
          'change': delta.change,
          'teacherId': teacherId,
          'teacherName': teacherName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Update group points atomically
      if (groupRef != null &&
          groupPointsDelta != null &&
          groupPointsDelta != 0) {
        final groupSnap = await transaction.get(groupRef);
        if (groupSnap.exists) {
          final groupData = groupSnap.data()!;
          final currentGroupTotal =
              (groupData['totalPoints'] as num?)?.toInt() ?? 0;
          transaction.update(groupRef, {
            'totalPoints': currentGroupTotal + groupPointsDelta,
          });
          log(
            '✍️ Group points updated from $currentGroupTotal to ${currentGroupTotal + groupPointsDelta}',
          );
        } else {
          log(
            '⚠️ Group document $groupID not found, skipping group points update',
          );
        }
      }

      if (otherFields != null && otherFields.isNotEmpty) {
        transaction.update(studentRef, otherFields);
      }

      log('✅ Transaction completed successfully');
    });
  }

  //   static Future<void> updateStudentWithHistory(
  //   StudentModel student,
  //   List<TayoHistoryChange> historyChanges,
  // ) async {
  //   final batch = firebase.batch();

  //   // Update student
  //   batch.update(
  //     studentCollection.doc(student.uid),
  //     student.toUpdateData(),
  //   );

  //   final historyCollection = studentCollection
  //       .doc(student.uid)
  //       .collection('history');

  //   final teacher = LocalHelper.getTeacherData();

  //   for (final change in historyChanges) {
  //     final historyDoc = historyCollection.doc();

  //     batch.set(
  //       historyDoc,
  //       TayoHistoryModel(
  //         category: change.category,
  //         change: change.change,
  //         createdAt: DateTime.now(), // or FieldValue.serverTimestamp() if your model supports it
  //         teacherId: teacher.uid,
  //         teacherName: teacher.name,
  //       ).toJson(),
  //     );
  //   }

  //   await batch.commit();
  // }

  static Future<void> updateStudentImage(
    String? studentId,
    String avatarUrl,
  ) async {
    await studentCollection.doc(studentId).update({'avatarUrl': avatarUrl});
  }

  static Future<void> addToAcceptedMissions(
    String? studentId,
    String mid,
  ) async {
    studentCollection.doc(studentId).update({
      "acceptedMissions": FieldValue.arrayUnion([mid]),
    });
  }

  static Future<void> removeFromAcceptedMissions(
    String? studentId,
    String mid,
  ) async {
    studentCollection.doc(studentId).update({
      "acceptedMissions": FieldValue.arrayRemove([mid]),
    });
  }

  static Future<void> updateSubmittedMissions(
    String? studentId,
    String mid,
    MissionModel mission,
  ) async {
    // missionCollection.doc(mid).update({
    //   'submissions.${studentId}': {
    //     'title': mission.title,
    //     'studentSolution': mission.studentSolution,
    //   },
    // });
    studentCollection.doc(studentId).update({
      'submittedMissions.$mid': {
        'title': mission.title,
        'studentSolution': mission.studentSolution,
      },
      'acceptedMissions': FieldValue.arrayRemove([mid]),
      'totalTayo': FieldValue.increment(int.parse(mission.reward ?? '0')),
    });
  }

  static Future<DocumentSnapshot<Object?>> getStudentByID(String? id) {
    return studentCollection.doc(id).get();
  }

  static Future<QuerySnapshot> getAllStudents() {
    return studentCollection.get();
  }

  static Future<QuerySnapshot> sortStudentsByTotalTayo() async {
    return await studentCollection.orderBy('totalTayo', descending: true).get();
  }

  static Stream<QuerySnapshot> streamedSortStudentsByTotalTayo(
    String? family,
    String? church,
  ) {
    // Stream students sorted by totalTayo in descending order
    // with a condition of family
    return studentCollection
        .where('family', isEqualTo: family)
        .where('church', isEqualTo: church)
        .orderBy('totalTayo', descending: true)
        .snapshots();
  }

  static Future<QuerySnapshot<Object?>> fetchStudentsByBirthday(
    String? churchName,
    String? family,
  ) async {
    Query query = studentCollection;

    if (family != null) {
      query = query.where('family', isEqualTo: family);
    }
    if (churchName != null) {
      query = query.where('church', isEqualTo: churchName);
    }

    return await query.orderBy('birthday', descending: true).get();
  }

  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ////////////////⚠️⚠️⚠️⚠️⚠️Tayo UPDATE METHODS⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  static Future<void> updateTayoInAllDocuments(
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories, {
    String? excludeStudentId,
  }) async {
    if ((tayoNewCategories?.isEmpty ?? true) &&
        (tayoRemovedCategories?.isEmpty ?? true)) {
      return;
    }

    // 1. Update config defaults
    final updates = updateTayoMethod(tayoNewCategories, tayoRemovedCategories);
    await configCollection.doc('defaults').update(updates);

    // 2. Fetch all students, skip the excluded one
    final snapshot = await studentCollection
        .where('church', isEqualTo: LocalHelper.getUserChurchName())
        .where('family', isEqualTo: LocalHelper.getUserFamily())
        .get();
    final docs = snapshot.docs;

    for (int i = 0; i < docs.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      final chunk = docs.sublist(i, (i + 500).clamp(0, docs.length));

      for (final doc in chunk) {
        if (excludeStudentId != null && doc.id == excludeStudentId) {
          continue; // skip
        }

        // If categories are being removed, we must adjust totalTayo
        Map<String, dynamic> docUpdates = Map<String, dynamic>.from(updates);
        if (tayoRemovedCategories != null && tayoRemovedCategories.isNotEmpty) {
          final data = doc.data();
          final tayo = Map<String, dynamic>.from(data['tayo'] ?? {});
          int totalTayo = (data['totalTayo'] ?? 0).toInt();

          for (final cat in tayoRemovedCategories) {
            if (tayo.containsKey(cat)) {
              final catData = tayo[cat] as Map<String, dynamic>?;
              totalTayo -= (catData?['count'] as num?)?.toInt() ?? 0;
            }
          }
          docUpdates['totalTayo'] = totalTayo;
        }
        batch.update(doc.reference, docUpdates);
      }

      await batch.commit();
    }
  }

  static Future<void> updateCurrentStudentTayo(
    String studentId,
    Map<String, dynamic> tayo,
    int totalTayo,
  ) async {
    // Update each tayo field individually instead of replacing the whole object
    Map<String, dynamic> updates = {'totalTayo': totalTayo};

    tayo.forEach((key, value) {
      updates['tayo.$key'] = value;
    });

    await studentCollection.doc(studentId).update(updates);
  }

  static Future<void> deleteStudent(String studentId) async {
    await studentCollection.doc(studentId).delete();
  }

  // MISSION METHODS ////////////////////////////////////////////////////////////
  static Future<void> createMission(MissionModel mission) async {
    await missionCollection.doc(mission.mid).set(mission.toJson());
  }

  static Future<void> deleteMission(String missionId) async {
    await missionCollection.doc(missionId).delete();
  }

  static Future<QuerySnapshot> fetchMissions() async {
    return await missionCollection.get();
  }

  static Future<QuerySnapshot> fetchStudentMissions(String studyLevel) async {
    final normalizedStudyLevel = studyLevel.trim();
    final levels = normalizedStudyLevel.isEmpty
        ? <String>['الكل']
        : <String>[normalizedStudyLevel, 'الكل'];

    return await missionCollection
        .where('missionStudyLevel', whereIn: levels)
        .get();
  }

  static Future<void> updateMission(MissionModel mission) async {
    await missionCollection.doc(mission.mid).update(mission.toUpdateData());
  }

  // GROUP METHODS //////////////////////////////////////////////////////////////
  static Future<String> createGroup(GroupModel group) async {
    final doc = await groupCollection.add(
      group.toJson(),
    ); // ← use add() not set()
    return doc.id;
  }

  static Future<void> deleteGroup(String groupId) async {
    await groupCollection.doc(groupId).delete();
  }

  static Future<QuerySnapshot> fetchGroupsByTotalPoints() async {
    return await groupCollection.orderBy('totalPoints', descending: true).get();
  }

  static Future<DocumentSnapshot<Object?>> getGroupbyId(String? groupId) async {
    return await groupCollection.doc(groupId ?? '').get();
  }

  static Future<void> updateGroup(GroupModel group) async {
    await groupCollection.doc(group.gid).update(group.toUpdateData());
  }

  static Future<void> updateGroupPoints({
    required String groupId,
    required int changeInPoints,
  }) async {
    final docRef = groupCollection.doc(groupId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Group not found');
      }

      final data = snapshot.data()! as Map<String, dynamic>;

      final currentPoints = data['totalPoints'] ?? 0;

      transaction.update(docRef, {
        'totalPoints': currentPoints + changeInPoints,
      });
    });
  }

  static Future<DocumentSnapshot<Object?>> getGroupByID(String groupId) async {
    return await groupCollection.doc(groupId).get();
  }

  static Future<void> updateGroupTotalTayo({
    required String groupId,
    required int totalTayo,
  }) async {
    await groupCollection.doc(groupId).update({'totalTayo': totalTayo});
  }

  /// Atomically applies Points deltas and records history.
  static Future<void> updateGroupWithHistory({
    required String groupId,
    required List<TayoHistoryModel> deltas,
    required List<String> removedCategories,
    required String teacherId,
    required String teacherName,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final groupRef = firestore.collection('Group').doc(groupId);
    final historyRef = groupRef.collection('history');

    log(
      'Starting transaction for group $groupId with deltas: $deltas and removedCategories: $removedCategories',
    );

    await firestore.runTransaction((transaction) async {
      // 1. Read current group
      final groupSnap = await transaction.get(groupRef);
      if (!groupSnap.exists) throw Exception('Group $groupId not found');
      final data = groupSnap.data()!;

      Map<String, dynamic> points = Map<String, dynamic>.from(
        data['points'] ?? {},
      );
      int totalPoints = (data['totalPoints'] ?? 0).toInt();

      // 2. Apply deltas
      for (final delta in deltas) {
        if (removedCategories.contains(delta.category)) continue;
        final change = delta.change ?? 0;

        // Allow zero‑change additions, but skip existing categories with no change
        if (change == 0 && points.containsKey(delta.category)) continue;

        final existing = points[delta.category];
        if (existing != null && existing is Map<String, dynamic>) {
          final current = (existing['count'] as num?)?.toInt() ?? 0;
          existing['count'] = current + change;
          existing['takenAt'] = FieldValue.serverTimestamp();
        } else {
          // New category – even if count is 0
          points[delta.category ?? ''] = {
            'count': change,
            'takenAt': FieldValue.serverTimestamp(), // or null if you prefer
          };
        }
        totalPoints += change; // change = 0 so totalPoints unchanged
      }

      // 3. Handle removed categories
      for (final cat in removedCategories) {
        if (points.containsKey(cat)) {
          final catData = points[cat] as Map<String, dynamic>;
          final count = (catData['count'] as num?)?.toInt() ?? 0;
          totalPoints -= count;
          points.remove(cat);
        }
      }

      // 4. Write group document
      transaction.update(groupRef, {
        'points': points,
        'totalPoints': totalPoints,
      });

      // 5. Write history documents
      for (final delta in deltas) {
        if (removedCategories.contains(delta.category)) continue;
        if ((delta.change ?? 0) == 0) continue;
        final historyDoc = historyRef.doc();
        transaction.set(historyDoc, {
          'category': delta.category,
          'change': delta.change,
          'teacherId': teacherId,
          'teacherName': teacherName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Adds / removes categories from ALL group documents (except `currentGroupId`)
  /// and updates the config defaults.
  static Future<void> propagateCategoryChanges({
    required String currentGroupId,
    required List<String> newCategories,
    required List<String> removedCategories,
  }) async {
    try {
      if (newCategories.isEmpty && removedCategories.isEmpty) return;

      // 1. Update the config defaults (dot‑notation works inside maps)
      final defaultsUpdates = <String, dynamic>{};
      for (final cat in newCategories) {
        defaultsUpdates['points.$cat'] = {'count': 0, 'takenAt': null};
      }
      for (final cat in removedCategories) {
        defaultsUpdates['points.$cat'] = FieldValue.delete();
      }
      await configCollection.doc('defaults').update(defaultsUpdates);

      // 2. Fetch all groups except the one currently being edited
      final allSnap = await groupCollection
          .where('groupChurch', isEqualTo: LocalHelper.getUserChurchName())
          .where('groupFamily', isEqualTo: LocalHelper.getUserFamily())
          .get();
      final otherGroups = allSnap.docs
          .where((doc) => doc.id != currentGroupId)
          .toList();

      if (otherGroups.isEmpty) return;

      // 3. Batch‑write in chunks of 500 (Firestore batch limit)
      for (int i = 0; i < otherGroups.length; i += 500) {
        final batch = firebase.batch();
        final chunk = otherGroups.sublist(
          i,
          (i + 500).clamp(0, otherGroups.length),
        );

        for (final doc in chunk) {
          final data = doc.data();
          final points = Map<String, dynamic>.from(data['points'] ?? {});
          int totalPoints = (data['totalPoints'] ?? 0).toInt();

          final updates = <String, dynamic>{};

          // Add new categories with count = 0 (totalPoints unchanged)
          for (final cat in newCategories) {
            updates['points.$cat.count'] = 0;
            updates['points.$cat.takenAt'] = null;
          }

          // Remove categories and subtract their current count from totalPoints
          for (final cat in removedCategories) {
            if (points.containsKey(cat)) {
              final catData = points[cat] as Map<String, dynamic>?;
              final count = (catData?['count'] as num?)?.toInt() ?? 0;
              totalPoints -= count;
              updates['points.$cat'] = FieldValue.delete();
            }
          }

          updates['totalPoints'] = totalPoints; // always correct the total
          batch.update(doc.reference, updates);
        }

        await batch.commit();
      }
    } on FirebaseException catch (e, stackTrace) {
      log(
        'Firestore Error'
        '\nCode: ${e.code}'
        '\nMessage: ${e.message}'
        '\nStack: $stackTrace',
      );
    } catch (e, stackTrace) {
      log('Unexpected Error: $e', stackTrace: stackTrace);
    }
  }

  // History Methods ////////////////////////////////////////////////////////////

  static Future<QuerySnapshot<Map<String, dynamic>>> getStudentTayoHistory(
    String studentId,
  ) async {
    return await studentCollection
        .doc(studentId)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getGroupPointsHistory(
    String groupId,
  ) async {
    return await groupCollection
        .doc(groupId)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .get();
  }

  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️POINTS UPDATE METHODS⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  static Future<void> updatePointsInAllGroups(
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  ) async {
    if ((pointNewCategories?.isEmpty ?? true) &&
        (pointRemovedCategories?.isEmpty ?? true)) {
      return;
    }

    final updates = updatePointMethod(
      pointNewCategories,
      pointRemovedCategories,
    );

    // Update config document if needed
    await configCollection.doc('defaults').update(updates);

    // Update all group documents in batches of 500
    final snapshot = await groupCollection.get();
    final docs = snapshot.docs;

    for (int i = 0; i < docs.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      final chunk = docs.sublist(i, (i + 500).clamp(0, docs.length));

      for (final doc in chunk) {
        batch.update(doc.reference, updates);
      }

      await batch.commit();
    }
  }

  static Map<String, dynamic> updatePointMethod(
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  ) {
    final Map<String, dynamic> updates = {};

    for (final category in pointNewCategories ?? []) {
      updates['points.$category'] = {'count': 0, 'takenAt': null};
    }

    for (final category in pointRemovedCategories ?? []) {
      updates['points.$category'] = FieldValue.delete();
    }

    return updates;
  }

  static Future<Map<String, dynamic>> getDefaultPoints() async {
    final doc = await configCollection.doc('defaults').get();
    return doc.get('points') as Map<String, dynamic>;
  }
  // Badge Methods //////////////////////////////////////////////////////////////

  static Future<void> createBadge(
    String badgeName,
    String badgeCloudinaryUrl,
  ) async {
    final church = LocalHelper.getUserChurchName();
    final family = LocalHelper.getUserFamily();

    // Using a composite ID prevents duplicates and allows easy de-duplication.

    await firebase.collection('badges').doc().set({
      'church': church,
      'family': family,
      'name': badgeName,
      'url': badgeCloudinaryUrl,
    }, SetOptions(merge: true));
  }

  static Future<List<BadgeModel>> getBadgesFor(
    String? church,
    String? family,
  ) async {
    final snapshot = await firebase
        .collection('badges')
        .where('church', isEqualTo: church)
        .where('family', isEqualTo: family)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              BadgeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // defaults METHODS //////////////////////////////////////////////////////////////
  static Future<void> updateDefaultsChurchName(
    String churchName,
    String? adminPin,
  ) async {
    await configCollection.doc('defaults').update({
      // the churchNames is a map where each where the keys are the church names and the value is the admin pass
      'churchNames': {churchName: adminPin},
    });
  }

  static Future<Map<String, dynamic>?>? getChurches() async {
    try {
      final doc = await configCollection.doc('defaults').get();
      final churches = doc.get('churchNames') as Map<String, dynamic>? ?? {};
      log('Fetched churches in Firebase: $churches');
      return churches;
    } catch (e) {
      log('Error fetching churches: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getDefaultTayo() async {
    final doc = await configCollection.doc('defaults').get();
    return doc.get('tayo') as Map<String, dynamic>;
  }

  static Future<Map<String, bool>>
  checkIfUpdateAvailableOrAppUnderMaintenance() async {
    final doc = await configCollection.doc('defaults').get();
    final isUpdateAvailable = doc.get('updateAvailable') as bool? ?? false;
    final isAppUnderMaintenance =
        doc.get('appUnderMaintenance') as bool? ?? false;
    return {
      'isUpdateAvailable': isUpdateAvailable,
      'isAppUnderMaintenance': isAppUnderMaintenance,
    };
  }

  static Future<void> addFieldToAllDocs(dynamic defaultValue) async {
    final snapshot = await studentCollection.get();

    // Firestore batch writes max 500 operations
    const batchSize = 500;

    for (int i = 0; i < snapshot.docs.length; i += batchSize) {
      final batch = firebase.batch();
      final chunk = snapshot.docs.skip(i).take(batchSize);

      for (final doc in chunk) {
        batch.update(doc.reference, {'family': defaultValue});
        // Alternative: batch.update(doc.reference, {fieldName: defaultValue});
      }

      await batch.commit();
      print('Batch ${i ~/ batchSize + 1} committed.');
    }

    print('All documents updated.');
  }

  /// FCM token COllection Methods
  /// Save or update an FCM token for a specific user.
  static Future<void> saveFCMToken({
    required String uid,
    required String token,

    String platform = 'android',
  }) async {
    // Document ID = token → automatically unique per device
    await fcmTokensCollection.doc(token).set({
      'token': token,
      'uid': uid,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete a token document (e.g. on logout).
  static Future<void> deleteFCMToken(String token) async {
    await fcmTokensCollection.doc(token).delete();
  }

  // MISS CHECK METHODS ////////////////////////////////////////////////////////

  /// Marks a student as visited today (or on [date] if provided).
  /// Updates only the `lastMissCheck` field — cheap write, no full doc replace.
  static Future<void> updateStudentLastMissCheck(
    String studentUid, {
    DateTime? date,
  }) async {
    await studentCollection.doc(studentUid).update({
      'lastMissCheck': Timestamp.fromDate(date ?? DateTime.now()),
    });
  }
}
