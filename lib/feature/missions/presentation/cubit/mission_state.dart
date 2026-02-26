import 'package:saint_paul/core/models/mission_model.dart';

class MissionState {}

class MissionInitialState extends MissionState {}

class MissionLoadingState extends MissionState {}

class MissionsLoadedState extends MissionState {
  final List<MissionModel>? missions;
  MissionsLoadedState({this.missions});
}

class MissionSuccessState extends MissionState {
  final String? message;
  MissionSuccessState({this.message});
}

class MissionErrorState extends MissionState {
  final String message;
  MissionErrorState({required this.message});
}
