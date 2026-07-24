import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:saint_paul/core/extentions/image_uploader.dart';
import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';

class HomeRepo {
  // This method updates a student's data, including their Tayo points and history.
  // It computes the changes in Tayo points, applies any global category changes,
  // retrieves teacher information, and performs an atomic update to the student's record in Firebase.
  // It also handles errors and returns appropriate messages based on the outcome of the operation.
  static Future<String?> updatStudent({
    required StudentModel newStudent,
    required StudentModel oldStudent,
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
    String? groupID,
    int? groupPointsDelta,
  }) async {
    try {
      // 1. Compute point deltas (no zero-deltas, no removed categories)
      final deltas = TayoHistoryModel.computeTayoChanges(
        oldTayo: oldStudent.tayo!,
        newTayo: newStudent.tayo!,
        removedCategories: tayoRemovedCategories ?? [],
      );

      log(
        'Deltas: ${deltas.map((d) => '${d.category}: ${d.change}').join(', ')}',
      );

      // 2. Optional: update all students if global categories changed
      if ((tayoNewCategories?.isNotEmpty ?? false) ||
          (tayoRemovedCategories?.isNotEmpty ?? false)) {
        await FirebaseProvider.applyFamilyTayoCategoryChanges(
          tayoNewCategories,
          tayoRemovedCategories,
          excludeStudentId: newStudent.uid ?? oldStudent.uid,
        );
      }

      // 3. Get teacher info
      log('Fetching teacher data from local storage...');
      final teacher = LocalHelper.getTeacherData();
      log('Teacher data from local storage: $teacher');

      if (teacher == null || teacher.uid == null || teacher.name == null) {
        return 'تعذر الحصول على بيانات المعلم. الرجاء تسجيل الدخول مجدداً.';
      }

      log('Teacher: uid=${teacher.uid}, name=${teacher.name}');

      // 4. Atomic student update + history (the ONLY write to this student’s tayo)
      log('Updating student ${newStudent.uid} with deltas: $deltas');

      final otherFields = newStudent.toUpdateData();
      otherFields.remove('tayo');
      otherFields.remove('totalTayo');

      await FirebaseProvider.updateStudentWithHistory(
        studentId: newStudent.uid ?? oldStudent.uid!,
        deltas: deltas,
        removedCategories: tayoRemovedCategories ?? [],
        teacherId: teacher.uid!,
        teacherName: teacher.name!,
        groupID: groupID,
        groupPointsDelta: groupPointsDelta,
        otherFields: otherFields.isNotEmpty ? otherFields : null,
      );

      log('✅ Student updated successfully.');

      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      throw Exception('Failed to update student: ${e.toString()}');
    } catch (e) {
      log('Unexpected error during student update in Repo: ${e.toString()}');
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  // This method retrieves the Tayo details for a specific student from Firebase.
  static Future<Map<String, dynamic>?> getStudentTayoDetails(
    StudentModel student,
  ) async {
    try {
      final snapshot = await FirebaseProvider.getStudentByID(student.uid ?? '');

      final data = ((snapshot.data()) as Map<String, dynamic>?) ?? {};

      return data['tayo'] as Map<String, dynamic>? ?? {};
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  // This method creates a new student record in Firebase.
  static Future<String?> createStudent(StudentModel student) async {
    try {
      await FirebaseProvider.createStudent(student);
      return 'تم إنشاء المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء إنشاء المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  // This method updates the "takenAt" field for a specific student in Firebase.
  static Future<String?> updatStudentTakenAt(StudentModel student) async {
    try {
      await FirebaseProvider.updateStudent(student);
      return 'تم تحديث بيانات المخدوم بنجاح.';
    } on Exception catch (e) {
      log(e.toString());
      return 'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.';
    }
  }

  // This method loads the study level (year) of a student from Firebase based on their ID.
  static Future<String?> loadStudentYear(String? id) async {
    try {
      if (id == null || id.isEmpty) {
        return ' ';
      }
      final snapshot = await FirebaseProvider.getStudentByID(id);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data['studyLevel'] as String?;
    } on Exception catch (e) {
      log(e.toString());
      return ' ';
    }
  }

  // This method loads the complete student data from Firebase based on their ID and returns a StudentModel object.
  static Future<StudentModel?> loadStudentData(String? id) async {
    try {
      final snapshot = await FirebaseProvider.getStudentByID(id);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final student = StudentModel.fromJson(data, snapshot.id);
      return student;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // This method updates the total Tayo points for a specific student group in Firebase.
  static Future<void> updateStudentGroup(
    String studentGroupId,
    int changesToTotalTayo,
  ) async {
    try {
      log(
        'Updating student group with ID: $studentGroupId, changes to total tayo: $changesToTotalTayo',
      );
      var snapshot = await FirebaseProvider.getGroupbyId(studentGroupId);
      if (snapshot.exists) {
        var group = GroupModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
        log(
          'Fetched group: ${group.gid} → ${group.name} with total tayo: ${group.totalTayo}',
        );
        await FirebaseProvider.updateGroup(
          group.copyWith(
            totalTayo: (group.totalTayo ?? 0) + changesToTotalTayo,
          ),
        );
        log(
          'Updated group total tayo to: ${(group.totalTayo ?? 0) + changesToTotalTayo}',
        );
      }
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('Failed to update student group: ${e.toString()}');
    }
  }

  // This method uploads a badge image to Cloudinary and returns the URL of the uploaded image.
  static Future<String?> uploadBadgeImageToCloudinary(
    String badgeName,
    String path,
  ) async {
    try {
      final cloudinaryUrl = await uploadImageToCloudinary(File(path));
      if (cloudinaryUrl == null) return null;
      log('Cloudinary URL: $cloudinaryUrl');

      return cloudinaryUrl; // ← return URL not Arabic string
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // This method retrieves the list of badges for the current user's church family from Firebase.
  static Future<List<BadgeModel>> getCurrentChurchFamilyBadges() async {
    try {
      final badges = await FirebaseProvider.getChurchFamilyBadges(
        LocalHelper.getUserChurchName(),
        LocalHelper.getUserFamily(),
      );
      log('Fetched badges from Firebase: $badges');
      return badges;
    } catch (e) {
      log(e.toString());
      return []; // Return an empty list on error
    }
  }

  // This method creates a new badge for the church family in Firebase.
  static Future<void> createBadge(String badgeName, String url) async {
    try {
      await FirebaseProvider.createBadgeForChurchFamily(badgeName, url);
    } on Exception catch (e) {
      log(e.toString());
      throw Exception('Failed to update badge in Firebase: ${e.toString()}');
    }
  }

  // This method adds a church name to all documents in the Students collection in Firebase.
  static Future<void> addChurchToAllDocs(String churchName) async {
    try {
      log(
        'Adding church "$churchName" to all documents in the Students collection...',
      );
      await FirebaseProvider.addFieldToAllDocs(churchName);
      log('Successfully added church "$churchName" to all documents.');
    } on Exception catch (e) {
      log(
        'Failed to add church "$churchName" to all documents: ${e.toString()}',
      );
      throw Exception('Failed to add church to all documents: ${e.toString()}');
    }
  }

  static Future<void> importStudentsFromExcel(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;

    if (sheet.rows.length <= 1) return;

    // Find the actual header row by locating the row containing "الاسم"
    int headerRowIndex = -1;
    for (int i = 0; i < sheet.rows.length; i++) {
      final rowValues = sheet.rows[i]
          .map((e) => e?.value.toString().trim() ?? "")
          .toList();
      if (rowValues.contains("الاسم")) {
        headerRowIndex = i;
        break;
      }
    }

    if (headerRowIndex == -1)
      return; // couldn't find a valid header row, bail out
    if (sheet.rows.length <= headerRowIndex + 1)
      return; // no data rows after header

    final headers = sheet.rows[headerRowIndex]
        .map((e) => e?.value.toString().trim() ?? "")
        .toList();

    final Map<String, Map<String, dynamic>> familyTayoCache = {};

    final church = LocalHelper.getUserChurchName();
    final existingByPhone =
        await FirebaseProvider.getExistingStudentsKeyedByPhone(church ?? '');

    List<StudentModel> newStudents = [];
    List<StudentModel> updatedStudents =
        []; // existing students with changed info

    // Start reading right after the real header row
    for (int i = headerRowIndex + 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      String value(String column) {
        final index = headers.indexOf(column);
        if (index == -1 || index >= row.length) return "";
        final cellValue = row[index]?.value;
        if (cellValue == null) return "";
        return cellValue.toString().trim();
      }

      final name = value("الاسم");
      if (name.isEmpty) continue; // skip blank/trailing rows

      final personalPhone = value("تلفون المخدوم");
      final existing = personalPhone.isNotEmpty
          ? existingByPhone[personalPhone]
          : null;

      DateTime? birthday;
      final birthdayText = value("تاريخ الميلاد");
      if (birthdayText.isNotEmpty) birthday = DateTime.tryParse(birthdayText);

      final family = value("الأسرة");
      if (family.isNotEmpty && !familyTayoCache.containsKey(family)) {
        familyTayoCache[family] =
            await FirebaseProvider.getChurchDefaultFamilyTayo(family);
      }

      if (existing != null) {
        // Student already exists — build an updated model but KEEP their uid,
        // and preserve fields the Excel doesn't know about (tayo, badges, missions)
        final updated = StudentModel(
          uid: existing.uid, // reuse existing uid, don't create a new doc
          name: name,
          family: family,
          studyLevel: value("المستوى الدراسي"),
          birthday: birthday,
          responsibleTeacher: value("الخادم"),
          address: value("العنوان (وصف او لينك google maps)"),
          personalPhone: personalPhone,
          fatherPhone: value("تلفون الأب"),
          motherPhone: value("تلفون الأم"),
          housePhone: value("تلفون المنزل"),
          church: church,
          avatarUrl: existing.avatarUrl,
          totalTayo: existing.totalTayo, // preserve
          tayo: existing.tayo, // preserve
          myBadges: existing.myBadges, // preserve
          acceptedMissions: existing.acceptedMissions, // preserve
          submittedMissions: existing.submittedMissions, // preserve
          lastMissCheck: existing.lastMissCheck, // preserve
        );
        updatedStudents.add(updated);
      } else {
        newStudents.add(
          StudentModel(
            uid: FirebaseFirestore.instance.collection("students").doc().id,
            name: name,
            family: family,
            studyLevel: value("المستوى الدراسي"),
            birthday: birthday,
            responsibleTeacher: value("الخادم"),
            address: value("العنوان (وصف او لينك google maps)"),
            personalPhone: personalPhone,
            fatherPhone: value("تلفون الأب"),
            motherPhone: value("تلفون الأم"),
            housePhone: value("تلفون المنزل"),
            church: church,
            avatarUrl: "",
            totalTayo: 0,
            tayo: familyTayoCache[family] ?? {},
            lastMissCheck: DateTime.now(),
          ),
        );
      }
    }

    if (newStudents.isEmpty && updatedStudents.isEmpty) return;

    // Save both groups — merge:true handles create-or-update safely either way
    if (newStudents.isNotEmpty) {
      await FirebaseProvider.updateStudentsBatch(newStudents);
    }
    if (updatedStudents.isNotEmpty) {
      await FirebaseProvider.updateStudentsBatch(updatedStudents);
    }
    // Optionally, clean up any students with empty or null names after the import
    // await FirebaseProvider.deleteStudentsWithEmptyOrNullName(church ?? '');
  }

  static Future<List<TeacherModel>> getChurchTeachers(String churchName) async {
    try {
      final teachers = await FirebaseProvider.getChurchTeachers(churchName);
      log('Fetched teachers from Firebase: $teachers');
      return teachers;
    } catch (e) {
      log('Error while fetching church teachers: ${e.toString()}');
      return []; // Return an empty list on error
    }
  }
}
