import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/student_model.dart';

class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileSuccessState extends ProfileState {
  final String? message;
  ProfileSuccessState({this.message});
}

class ProfileLoadedState extends ProfileState {
  final StudentModel? studentData;
  final String? message;

  ProfileLoadedState({this.message, this.studentData});
}

class ProfileBadgesLoadedState extends ProfileState {
  final List<BadgeModel> badges;
  ProfileBadgesLoadedState({required this.badges});
}

// Holds the students list and the currently selected IDs
class ProfileAssignedStudentsLoadedState extends ProfileState {
  final List<StudentModel> students;
  final List<String> selectedStudentIds;

  ProfileAssignedStudentsLoadedState({
    required this.students,
    required this.selectedStudentIds,
  });
}

class TeacherStudentsLoading extends ProfileState {}

class ProfileDeletedState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState({required this.message});
}
