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
  var groupTotalTayo = 0;

  Future<void> deleteGroup(GroupModel group) async {
    emit(GroupLoadingState());
    try {
      final futures = group.students?.map(
        (studentId) => FirebaseProvider.updateStudentGroupID(studentId, ''),
      );
      await Future.wait(futures?.toList() ?? []);
      await GroupsRepo.deleteGroup(group.gid ?? '');
      emit(GroupDeleteSuccessState(message: 'تم حذف المجموعة بنجاح.'));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء حذف المجموعة: ${e.toString()}'));
    }
  }

  Future<String?> createGroup(
    List<String> studentIds,
    String studyLevel,
  ) async {
    try {
      groupTotalTayo = 0; // reset after
      final students = await GroupsRepo.fetchStudentsByIds(studentIds);
      for (var student in students) {
        log(
          'Fetched student: ${student.uid} → ${student.name} with total tayo: ${student.totalTayo}',
        );
        groupTotalTayo += student.totalTayo ?? 0;
      }
      log('Total tayo for selected students: $groupTotalTayo');
      final groupId = await FirebaseProvider.createGroup(
        GroupModel(
          name: groupNameController.text.trim(),
          students: studentIds,
          totalTayo: groupTotalTayo,
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
      for (var student in students) {
        log('Fetched student: ${student.uid} → ${student.name}');
        groupTotalTayo += student.totalTayo ?? 0;
      }
      emit(
        StudentsLoadedSuccessState(
          students: students,
          totalTayo: groupTotalTayo,
        ),
      );
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
      log(
        'Fetched student snapshot for ID $studentId: ${snapshot.id} → ${snapshot.data()}',
      );
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      log('Fetched student data for ID $studentId: $data');
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
      emit(
        StudentsLoadedSuccessState(
          students: students,
          group: group,
          totalTayo: group.totalTayo ?? 0,
        ),
      );
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعة: ${e.toString()}'));
    }
  }

  Future<void> techersGroupDetails(GroupModel? group) async {
    emit(GroupLoadingState());
    try {
      final students = await GroupsRepo.fetchStudentsByIds(
        group?.students ?? [],
      );
      emit(StudentsLoadedSuccessState(students: students, group: group));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعة: ${e.toString()}'));
    }
  }

  Future<void> fetchAndUpdateTotalTayo(GroupModel? group) async {
    emit(GroupLoadingState());
    try {
      final students = await GroupsRepo.fetchStudentsByIds(
        group?.students ?? [],
      );
      log(
        'Fetched students for group ${group?.gid}: ${students.length} students',
      );
      groupTotalTayo = 0; // reset before calculating
      for (var student in students) {
        log(
          'Fetched student: ${student.uid} → ${student.name} with total tayo: ${student.totalTayo}',
        );
        groupTotalTayo += student.totalTayo ?? 0;
      }
      if (groupTotalTayo != group?.totalTayo) {
        log(
          'Updating group total tayo from ${group?.totalTayo} to $groupTotalTayo',
        );
        await GroupsRepo.updateGroup(
          group!.copyWith(totalTayo: groupTotalTayo),
        );
        log('Group total tayo updated successfully');
        log(
          'Emitting updated group details with new total tayo: $groupTotalTayo',
        );
        log(
          'Group details: ${group.copyWith(totalTayo: groupTotalTayo).toJson()}',
        );
        emit(
          StudentsLoadedSuccessState(
            students: students,
            group: group.copyWith(totalTayo: groupTotalTayo),
          ),
        );
      } else {
        log('No update needed for group total tayo: $groupTotalTayo');
        log(
          'Emitting group details with existing total tayo: ${group?.totalTayo}',
        );
        log('Group details: ${group?.toJson()}');
        emit(StudentsLoadedSuccessState(students: students, group: group));
      }
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعة: ${e.toString()}'));
    }
  }
}
