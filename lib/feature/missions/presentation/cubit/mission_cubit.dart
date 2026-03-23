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
  String? selectedValue;

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
        missionStudyLevel: selectedValue,
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
      emit(MissionDeleteSuccessState(message: result));
      await fetchMissions();
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
      var acceptedMissions = await MissionRepo.fetchAcceptedMissions();
      final submittedMissions = await MissionRepo.fetchSubmittedMissions();

      log(' Fetched missions: ${missions.length}');
      log(
        'First mission title: ${missions.isNotEmpty ? missions[0].title : 'No missions'}',
      );
      log(
        'First mission description: ${missions.isNotEmpty ? missions[0].description : 'No missions'}',
      );
      log('Accepted missions: ${acceptedMissions.length}');
      log('Accepted missions IDs: $acceptedMissions');

      emit(
        MissionsLoadedState(
          missions: missions,
          acceptedMissions: acceptedMissions,
          submittedMissions: submittedMissions,
        ),
      );
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء تحميل المهام. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<String> acceptMission(String mid) async {
    emit(MissionLoadingState());
    try {
      final result = await MissionRepo.acceptMission(mid);
      emit(MissionSuccessState(message: result));
      return 'تم قبول المهمة بنجاح.';
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء قبول المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
      return 'حدث خطأ أثناء قبول المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  Future<String> removeFromAcceptedMissions(String mid) async {
    emit(MissionLoadingState());
    try {
      final result = await MissionRepo.removeFromAcceptMission(mid);
      emit(MissionSuccessState(message: result));
      return 'تم إلغاء قبول المهمة بنجاح.';
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء إلغاء قبول المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
      return 'حدث خطأ أثناء إلغاء قبول المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  Future<String> submitMission(String mid, MissionModel mission) async {
    emit(MissionLoadingState());
    try {
      final result = await MissionRepo.submitMission(mid, mission);
      emit(MissionSuccessState(message: result));
      return 'تم إرسال المهمة بنجاح.';
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء إرسال المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
      return 'حدث خطأ أثناء إرسال المهمة. الرجاء المحاولة مرة أخرى.';
    }
  }

  void loadMissionControllers(MissionModel? mission) {
    titleController.text = mission?.title ?? '';
    descriptionController.text = mission?.description ?? '';
    linkController.text = mission?.link ?? '';
    rewardController.text = mission?.reward ?? '';
    expireAfterController.text = mission?.expireAfter.toString() ?? '';
  }

  Future<void> updateMission(MissionModel missionEdit) async {
    emit(MissionLoadingState());
    try {
      final result = await MissionRepo.updateMission(missionEdit);
      emit(MissionSuccessState(message: result));
    } catch (e) {
      emit(
        MissionErrorState(
          message: 'حدث خطأ أثناء تحديث المهمة. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }
}
