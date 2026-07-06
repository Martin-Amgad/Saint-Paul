import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';

class FirebaseProvider {
  static final FirebaseFirestore firebase = FirebaseFirestore.instance;

  static final CollectionReference studentCollection = firebase.collection(
    'Student',
  );

  static final CollectionReference teacherCollection = firebase.collection(
    'Teacher',
  );

  static final CollectionReference missionCollection = firebase.collection(
    'Mission',
  );
  static final CollectionReference groupCollection = firebase.collection(
    'Group',
  );
  static final CollectionReference configCollection = firebase.collection(
    'config',
  );

  // TEACHER METHODS ////////////////////////////////////////////////////////////
  static Future<void> createTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).set(teacher.toJson());
  }

  static Future<void> updateTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).update(teacher.toUpdateData());
  }

  static Future<DocumentSnapshot<Object?>> getTeacherByID(String? id) {
    return teacherCollection.doc(id).get();
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

  /// Atomically applies Tayo deltas and records history.
  static Future<void> updateStudentWithHistory({
    required String studentId,
    required List<TayoHistoryModel> deltas,
    required List<String> removedCategories,
    required String teacherId,
    required String teacherName,
    String? groupID,
    int? groupPointsDelta,
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

  static Stream<QuerySnapshot> streamedSortStudentsByTotalTayo() {
    return studentCollection.orderBy('totalTayo', descending: true).snapshots();
  }

  static Future<QuerySnapshot> fetchStudentsByBirthday() async {
    return await studentCollection.orderBy('birthday', descending: true).get();
  }

  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  ////////////////⚠️⚠️⚠️⚠️⚠️Tayo UPDATE METHODS⚠️⚠️⚠️⚠️⚠️
  ///////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
  static Future<void> updateTayoInAllDocuments(
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  ) async {
    if ((tayoNewCategories?.isEmpty ?? true) &&
        (tayoRemovedCategories?.isEmpty ?? true)) {
      return;
    }

    final updates = updateTayoMethod(tayoNewCategories, tayoRemovedCategories);

    // update config doc
    await configCollection.doc('defaults').update(updates);

    // update all student docs in batches of 500
    final snapshot = await studentCollection.get();
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
    await FirebaseFirestore.instance.collection('Group').doc(groupId).update({
      'totalTayo': totalTayo,
    });
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
        final change = delta.change ?? 0; // handle nullable change
        if (change == 0) continue;

        final existing = points[delta.category];
        if (existing != null && existing is Map<String, dynamic>) {
          final current = (existing['count'] as num?)?.toInt() ?? 0;
          existing['count'] = current + change;
          existing['takenAt'] = FieldValue.serverTimestamp();
        } else {
          points[delta.category ?? ''] = {
            'count': change,
            'takenAt': FieldValue.serverTimestamp(),
          };
        }
        totalPoints += change;
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
    await configCollection.doc('defaults').update({
      'badges.$badgeName': badgeCloudinaryUrl, // just the URL, no nested map
    });
  }

  static Future<Map<String, String>> getBadges() async {
    final doc = await configCollection.doc('defaults').get();
    return Map<String, String>.from(doc.get('badges') as Map? ?? {});
  }

  static Future<void> migrateListToMap() async {
    final snapshot = await studentCollection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final badges = data['missionBadges']; // read from old name

      if (badges is List) {
        final badgesAsMap = {
          for (final badge in badges) badge.toString(): true,
        };
        batch.update(doc.reference, {
          'myBadges': badgesAsMap, // write to new name
          'missionBadges': FieldValue.delete(), // delete old field
        });
      }
    }

    await batch.commit();
  }

  // defaults METHODS //////////////////////////////////////////////////////////////
  static Future<Map<String, dynamic>> getDefaultTayo() async {
    final doc = await configCollection.doc('defaults').get();
    return doc.get('tayo') as Map<String, dynamic>;
  }

  static Future<bool> checkIfUpdateAvailable() async {
    final doc = await configCollection.doc('defaults').get();
    return doc.get('updateAvailable') as bool? ?? false;
  }

  static Future<bool> checkIfAppUnderMaintenance() async {
    final doc = await configCollection.doc('defaults').get();
    return doc.get('appUnderMaintenance') as bool? ?? false;
  }
}
