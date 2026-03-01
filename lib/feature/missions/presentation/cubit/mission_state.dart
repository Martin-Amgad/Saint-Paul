import 'package:saint_paul/core/models/mission_model.dart';

class MissionState {}

class MissionInitialState extends MissionState {}

class MissionLoadingState extends MissionState {}

class MissionsLoadedState extends MissionState {
  final List<MissionModel>? missions;
  final List<String>? acceptedMissions;
  final List<String>? submittedMissions;

  MissionsLoadedState({
    this.acceptedMissions,
    this.missions,
    this.submittedMissions,
  });
}

class MissionSubmittedLoadedState extends MissionState {
  final List<String> submittedMissions;
  MissionSubmittedLoadedState({required this.submittedMissions});
}

class MissionSuccessState extends MissionState {
  final String? message;
  MissionSuccessState({this.message});
}

class MissionDeleteSuccessState extends MissionState {
  final String? message;
  MissionDeleteSuccessState({this.message});
}

class MissionErrorState extends MissionState {
  final String message;
  MissionErrorState({required this.message});
}
