import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/feature/missions/data/repo/missions_repo.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';

class MissionCubit extends Cubit<MissionState> {
  MissionCubit() : super(MissionInitialState());

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var rewardController = TextEditingController();
  var linkController = TextEditingController();
  var expireAfterController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  Future<void> createMission() async {
    emit(MissionLoadingState());
    try {
      final mission = MissionModel(
        title: titleController.text,
        description: descriptionController.text,
        link: linkController.text,
        reward: rewardController.text,
        expireAfter: int.tryParse(expireAfterController.text) ?? 0,
        currentDate: DateTime.now(),
      );
      final result = await MissionRepo.createMission(mission);
      emit(MissionSuccessState(message: result));
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء إنشاء المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> deleteMission(String mid) async {
    emit(MissionLoadingState());
    try {
      final result = await MissionRepo.deleteMission(mid);
      emit(MissionSuccessState(message: result));
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء حذف المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> fetchMissions() async {
    emit(MissionLoadingState());
    try {
      log('Fetching missions...');
      var missions = await MissionRepo.fetchMissions();
      log(' Fetched missions: ${missions.length}');
      log(
        'First mission title: ${missions.isNotEmpty ? missions[0].title : 'No missions'}',
      );
      log(
        'First mission description: ${missions.isNotEmpty ? missions[0].description : 'No missions'}',
      );

      emit(MissionsLoadedState(missions: missions));
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء تحميل المهام. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }
}
