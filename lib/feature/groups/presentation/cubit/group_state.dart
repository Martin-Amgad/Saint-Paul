import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/student_model.dart';

class GroupState {}

class GroupInitialState extends GroupState {}

class GroupSuccessState extends GroupState {}

class GroupLoadingState extends GroupState {}

class GroupErrorState extends GroupState {
  final String message;
  GroupErrorState(this.message);
}

class GroupDeleteSuccessState extends GroupState {
  final String? message;
  GroupDeleteSuccessState({this.message});
}

class GroupsLoadedSuccessState extends GroupState {
  final List<GroupModel> groups;
  GroupsLoadedSuccessState({required this.groups});
}

class StudentsLoadedSuccessState extends GroupState {
  final List<StudentModel> students;
  final GroupModel? group;
  final int? totalTayo;
  StudentsLoadedSuccessState({
    required this.students,
    this.group,
    this.totalTayo = 0,
  });
}

class GroupDetailsLoadedState extends GroupState {
  final GroupModel group;
  GroupDetailsLoadedState({required this.group});
}

class GroupDetailsErrorState extends GroupState {
  final String message;
  GroupDetailsErrorState(this.message);
}

class GroupNotAssignedState extends GroupState {}
