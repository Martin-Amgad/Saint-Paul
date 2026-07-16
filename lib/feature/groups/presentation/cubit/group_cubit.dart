import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/groups/data/repo/groups_repo.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupInitialState());

  var formKey = GlobalKey<FormState>();
  var groupNameController = TextEditingController();
  var groupTotalTayo = 0;
  int groupTotalPoints = 0;

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

  Future<void> updateGroup(
    GroupModel group, {
    required Map<String, dynamic> oldPoints, // ← new
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  }) async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.updateGroup(
        group,
        oldPoints: oldPoints,
        pointNewCategories: pointNewCategories,
        pointRemovedCategories: pointRemovedCategories,
      );
      log('Group updated successfully: $res');
      if (!isClosed) emit(GroupSuccessState(message: res));
    } catch (e) {
      if (!isClosed) {
        emit(GroupErrorState('حدث خطأ أثناء تحديث المجموعة: ${e.toString()}'));
      }
    }
  }

  Future<void> createGroup(List<String> studentIds, String studyLevel) async {
    emit(GroupLoadingState());

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

      final defaultPoints = await FirebaseProvider.getDefaultPoints();

      final groupId = await FirebaseProvider.createGroup(
        GroupModel(
          name: groupNameController.text.trim(),
          students: studentIds,
          totalTayo: groupTotalTayo,
          studyLevel: studyLevel,
          points: defaultPoints,
          groupChurch: LocalHelper.getUserChurchName(),
          groupFamily: LocalHelper.getUserFamily(),
        ),
      );

      final futures = studentIds.map(
        (id) => FirebaseProvider.updateStudentGroupID(id, groupId),
      );

      await Future.wait(futures);
      if (isClosed) return;
      emit(GroupSuccessState(message: 'تم إنشاء المجموعة بنجاح.'));
    } on Exception catch (e) {
      log('Error during group creation: ${e.toString()}');
      emit(GroupErrorState('حدث خطأ أثناء إنشاء المجموعة: ${e.toString()}'));
    } catch (e) {
      log('Unexpected error during group creation: $e');
      emit(GroupErrorState('حدث خطأ غير متوقع أثناء إنشاء المجموعة.'));
    }
  }

  Future<void> fetchGroups() async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.fetchGroups();
      if (isClosed) return;
      emit(GroupsLoadedSuccessState(groups: res));
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعات: ${e.toString()}'));
    }
  }

  Future<void> fetchGroup(String groupId) async {
    log("fetchGroup START");
    emit(GroupLoadingState());

    try {
      final group = await GroupsRepo.fetchGroup(groupId);
      log("fetchGroup FINISHED");
      log(">>> EMITTING GroupLoadedState");
      if (isClosed) return;
      emit(GroupLoadedState(group: group ?? GroupModel()));
      log(">>> GroupLoadedState emitted");
    } catch (e) {
      log("fetchGroup ERROR: $e");
      emit(GroupErrorState(e.toString()));
    }
  }

  Future<void> fetchStudents(String? family, String? churchName) async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.fetchStudents(family, churchName);
      if (isClosed) return;
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
      if (isClosed) return;
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

  Future<void> fetchAndCheckStudentGroup(String? studentId) async {
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
      if (isClosed) return;

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

  Future<void> teachersGroupDetails(GroupModel? group) async {
    emit(GroupLoadingState());
    try {
      final students = await GroupsRepo.fetchStudentsByIds(
        group?.students ?? [],
      );
      final newGroup = await GroupsRepo.fetchGroup(group?.gid);
      log(
        'Fetched students for group ${group?.gid}: Total Points = ${newGroup?.totalPoints}',
      );
      if (isClosed) return;
      emit(StudentsLoadedSuccessState(students: students, group: newGroup));
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
        await GroupsRepo.updateGroupTotalTayo(group!.gid!, groupTotalTayo);
        log('Group total tayo updated successfully');
        log(
          'Emitting updated group details with new total tayo: $groupTotalTayo',
        );
        log(
          'Group details: ${group.copyWith(totalTayo: groupTotalTayo).toJson()}',
        );
        if (isClosed) return;

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
        if (isClosed) return;
        emit(StudentsLoadedSuccessState(students: students, group: group));
      }
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء جلب المجموعة: ${e.toString()}'));
    }
  }

  Future<void> updateTotalPoints(GroupModel? group, int changeInPoints) async {
    if (changeInPoints == 0) return;

    try {
      await GroupsRepo.updateGroupPoints(
        groupId: group!.gid!,
        changeInPoints: changeInPoints,
      );
    } catch (e) {
      emit(GroupErrorState('حدث خطأ أثناء تحديث النقاط: $e'));
    }
  }

  void updateGroupTakenAt(
    GroupModel group, {
    List<String>? pointNewCategories,
    List<String>? pointRemovedCategories,
  }) async {
    try {
      await GroupsRepo.updateGroupTakenAt(group);
      if (isClosed) return;

      emit(GroupSuccessState(message: 'تم تحديث بيانات المجموعة بنجاح.'));
    } on Exception catch (e) {
      log(e.toString());
      emit(GroupErrorState(e.toString()));
    } catch (e) {
      log(e.toString());
      emit(
        GroupErrorState(
          'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  void getGroupPointsDetails(GroupModel group) async {
    emit(GroupLoadingState());
    try {
      var res = await GroupsRepo.getGroupPointsDetails(group);
      if (isClosed) return;

      if (res != null) {
        log('Group details retrieved successfully: $res');
        emit(GroupPointsLoadSuccessState(point: res));
      } else {
        log('No student details found for the given student.');
      }
    } on Exception catch (e) {
      log(e.toString());
      emit(GroupErrorState(e.toString()));
    }
  }
}
