import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/profile/data/repo/profile_repo.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());
  var nameController = TextEditingController();
  var fatherPhoneController = TextEditingController();
  var motherPhoneController = TextEditingController();
  var personalPhoneController = TextEditingController();
  var housePhoneController = TextEditingController();
  var addressController = TextEditingController();
  var studyLevelController = TextEditingController();
  var birthdayController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  var formkey = GlobalKey<FormState>();

  final teacherNameController = TextEditingController();
  String? teacherFamilySelectedValue;
  String? teacherAssignedYearSelectedValue;
  String? teacherAssignedRoleSelectedValue;

  List<String> selectedStudentIds = [];

  void loadStudentData(String? id) async {
    emit(ProfileLoadingState());
    try {
      StudentModel? res = await ProfileRepo.loadStudentData(id);
      emit(ProfileLoadedState(studentData: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(
        ProfileErrorState(
          message:
              'حدث خطأ أثناء تحميل بيانات الطالب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<String?> updateStudentImage(String path) async {
    try {
      log('Starting image update with path: $path');
      final newUrl = await ProfileRepo.updateStudentImage(path);
      log('New image URL: $newUrl');
      return newUrl; // ← just return the URL, screen handles the rest
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      emit(ProfileLoadingState());
      await ProfileRepo.deleteStudent(studentId);
      emit(ProfileDeletedState());
    } catch (e) {
      log(e.toString());
      emit(
        ProfileErrorState(
          message: 'حدث خطأ أثناء حذف الطالب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> loadBadges(String church, String family) async {
    emit(ProfileLoadingState());
    try {
      final badges = await ProfileRepo.getBadgesFor(church, family);
      emit(ProfileBadgesLoadedState(badges: badges));
    } catch (e) {
      emit(ProfileErrorState(message: e.toString()));
    }
  }

  Future<void> deleteTeacher(String teacherId) async {
    emit(ProfileLoadingState());
    try {
      await ProfileRepo.deleteTeacher(teacherId);
      emit(ProfileDeletedState());
    } catch (e) {
      emit(ProfileErrorState(message: e.toString()));
    }
  }

  void loadTeacherControllers(TeacherModel? teacher) {
    if (teacher != null) {
      teacherNameController.text = teacher.name ?? '';
      teacherFamilySelectedValue = teacher.assignedFamily ?? '';
      teacherAssignedYearSelectedValue = teacher.assignedStudyLevel ?? '';
    } else {
      teacherNameController.clear();
      teacherFamilySelectedValue = null;
      teacherAssignedYearSelectedValue = null;
    }
  }

  Future<void> updateTeacher({required TeacherModel newTeacher}) async {
    emit(ProfileLoadingState()); // show loading indicator

    try {
      log(
        'Updating teacher: ${newTeacher.name}, Family: ${newTeacher.assignedFamily}, Year: ${newTeacher.assignedStudyLevel}',
      );
      await ProfileRepo.updateTeacher(newTeacher);
      log('Teacher updated successfully: ${newTeacher.name}');

      if (isClosed) return;
      emit(ProfileSuccessState(message: 'تم تحديث بيانات الخادم بنجاح'));
    } catch (e) {
      emit(ProfileErrorState(message: e.toString()));
    }
  }

  Future<void> loadAssignedStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) {
      emit(
        ProfileAssignedStudentsLoadedState(
          students: [],
          selectedStudentIds: [],
        ),
      );
      return;
    }
    try {
      final students = await ProfileRepo.fetchStudentsByIds(studentIds);
      emit(
        ProfileAssignedStudentsLoadedState(
          students: students,
          selectedStudentIds: studentIds,
        ),
      );
    } catch (e) {
      emit(ProfileErrorState(message: 'فشل تحميل الطلاب المسندين'));
    }
  }

  Future<void> saveTeacherStudents({
    required String teacherId,
    required List<String> selectedIds,
    required List<String> previousIds,
  }) async {
    final added = selectedIds.where((id) => !previousIds.contains(id)).toList();
    final removed = previousIds
        .where((id) => !selectedIds.contains(id))
        .toList();

    emit(ProfileLoadingState());
    try {
      await ProfileRepo.updateTeacherStudents(
        teacherId: teacherId,
        assignedStudentIds: selectedIds,
        addedStudentIds: added,
        removedStudentIds: removed,
      );
      emit(ProfileSuccessState(message: 'تم حفظ الطلاب المسندين بنجاح'));
    } catch (e) {
      emit(ProfileErrorState(message: 'حدث خطأ أثناء الحفظ'));
    }
  }
}
