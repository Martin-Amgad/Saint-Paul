import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

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
  // TEACHER METHODS
  static Future<void> createTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).set(teacher.toJson());
  }

  static Future<void> updateTeacher(TeacherModel teacher) async {
    await teacherCollection.doc(teacher.uid).update(teacher.toUpdateData());
  }

  static Future<DocumentSnapshot<Object?>> getTeacherByID(String? id) {
    return teacherCollection.doc(id).get();
  }

  // STUDENT METHODS
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

  static Future<void> updateStudentImage(
    String? studentId,
    String avatarUrl,
  ) async {
    await studentCollection.doc(studentId).update({'avatarUrl': avatarUrl});
  }

  static Future<void> updateAcceptedMissions(
    String? studentId,
    String mid,
  ) async {
    studentCollection.doc(studentId).update({
      "acceptedMissions": FieldValue.arrayUnion([mid]),
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

  static Future<void> updateTayoInAllDocuments(
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  ) async {
    if ((tayoNewCategories?.isEmpty ?? true) &&
        (tayoRemovedCategories?.isEmpty ?? true)) {
      return;
    }

    final snapshot = await studentCollection.get();

    final futures = snapshot.docs.map((doc) {
      Map<String, dynamic> updates = {};

      for (var key in tayoNewCategories ?? []) {
        updates['tayo.$key.count'] = 0;
        updates['tayo.$key.takenAt'] = null;
      }

      for (var key in tayoRemovedCategories ?? []) {
        updates['tayo.$key'] = FieldValue.delete();
      }

      return doc.reference.update(updates);
    });

    await Future.wait(futures);

    tayoNewCategories?.clear();
    tayoRemovedCategories?.clear();
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

  // MISSION METHODS
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
    return await missionCollection
        .where('missionStudyLevel', isEqualTo: studyLevel)
        .get();
  }

  static Future<void> updateMission(MissionModel mission) async {
    await missionCollection.doc(mission.mid).update(mission.toUpdateData());
  }

  // GROUP METHODS
  static Future<String> createGroup(GroupModel group) async {
    final doc = await groupCollection.add(
      group.toJson(),
    ); // ← use add() not set()
    return doc.id;
  }

  static Future<void> deleteGroup(String groupId) async {
    await groupCollection.doc(groupId).delete();
  }

  static Future<QuerySnapshot> fetchGroupsByTotalTayo() async {
    return await groupCollection.orderBy('totalTayo', descending: true).get();
  }

  static Future<DocumentSnapshot<Object?>> getGroupbyId(String? groupId) async {
    return await groupCollection.doc(groupId ?? '').get();
  }

  static Future<void> updateGroup(GroupModel group) async {
    await groupCollection.doc(group.gid).update(group.toUpdateData());
  }
}
