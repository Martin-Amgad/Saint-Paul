import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/feature/groups/data/repo/groups_repo.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupInitialState());

  var formKey = GlobalKey<FormState>();
  var groupNameController = TextEditingController();

  Future<void> deleteGroup(GroupModel group) async {
    emit(GroupLoadingState());
    try {
      final futures = group.students?.map(
        (studentId) => FirebaseProvider.updateStudentGroupID(studentId, ''),
      );
      await Future.wait(futures?.toList() ?? []);
      await FirebaseProvider.deleteGroup(group.gid!);
      emit(GroupDeleteSuccessState(message: 'تم حذف المجموعة بنجاح.'));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء حذف المجموعة: ${e.toString()}'));
    }
  }

  Future<String?> createGroup(
    List<String> studentIds,
    int totalTayo,
    String studyLevel,
  ) async {
    try {
      final groupId = await FirebaseProvider.createGroup(
        GroupModel(
          name: groupNameController.text.trim(),
          students: studentIds,
          totalTayo: totalTayo,
          studyLevel: studyLevel,
        ),
      );
      final futures = studentIds.map(
        (id) => FirebaseProvider.updateStudentGroupID(id, groupId),
      );
      await Future.wait(futures);
      return 'تم إنشاء المجموعة بنجاح.';
    } on Exception catch (e) {
      return 'حدث خطأ أثناء إنشاء المجموعة: ${e.toString()}';
    } catch (e) {
      return 'حدث خطأ غير متوقع أثناء إنشاء المجموعة.';
    }
  }

  Future<void> fetchGroups() async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.fetchGroups();
      emit(GroupsLoadedSuccessState(groups: res));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعات: ${e.toString()}'));
    }
  }

  Future<void> fetchStudents() async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.fetchStudents();
      emit(StudentsLoadedSuccessState(students: res));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعات: ${e.toString()}'));
    }
  }

  Future<void> fetchGroupStudents(List<String> ids) async {
    emit(GroupLoadingState());
    try {
      final students = await GroupsRepo.fetchStudentsByIds(ids);
      emit(StudentsLoadedSuccessState(students: students));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المخدومين: ${e.toString()}'));
    }
  }

  Future<void> fetchStudentGroup(String? studentId) async {
    if (studentId == null || studentId.isEmpty) {
      emit(GroupNotAssignedState());
      return;
    }
    emit(GroupLoadingState());
    try {
      final snapshot = await FirebaseProvider.getStudentByID(studentId);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final groupId = data['groupID'] as String?;

      if (groupId == null || groupId.isEmpty) {
        emit(GroupNotAssignedState());
        return;
      }

      final group = await GroupsRepo.fetchGroup(groupId);
      if (group == null) {
        emit(GroupNotAssignedState());
        return;
      }

      final students = await GroupsRepo.fetchStudentsByIds(
        group.students ?? [],
      );
      emit(StudentsLoadedSuccessState(students: students, group: group));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعة: ${e.toString()}'));
    }
  }
}
