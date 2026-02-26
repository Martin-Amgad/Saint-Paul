import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';

class FirebaseProvider {
  static final FirebaseFirestore firebase = FirebaseFirestore.instance;

  static final CollectionReference studentCollection = firebase.collection(
    'Student',
  );

  static final CollectionReference missionCollection = firebase.collection(
    'Mission',
  );

  static Future<void> createStudent(StudentModel student) async {
    await studentCollection.doc(student.uid).set(student.toJson());
  }

  static Future<void> createMission(MissionModel mission) async {
    await missionCollection.doc(mission.mid).set(mission.toJson());
  }

  static Future<void> deleteMission(String missionId) async {
    await missionCollection.doc(missionId).delete();
  }

  static Future<QuerySnapshot> fetchMissions() async {
    return await missionCollection.get();
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
}
