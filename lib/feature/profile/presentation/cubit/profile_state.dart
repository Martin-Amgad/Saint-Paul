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

class ProfileDeletedState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState({required this.message});
}
