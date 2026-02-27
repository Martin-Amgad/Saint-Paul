import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/profile/data/repo/profile_repo.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());
  var nameController = TextEditingController();
  var fatherPhoneController = TextEditingController();
  var motherPhoneController = TextEditingController();
  var personalPhoneController = TextEditingController();
  var housePhoneController = TextEditingController();
  var addressController = TextEditingController();
  var studyLevelController = TextEditingController();
  var birthdayController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  var formkey = GlobalKey<FormState>();

  void loadStudentData(String? id) async {
    emit(ProfileLoadingState());
    try {
      StudentModel? res = await ProfileRepo.loadStudentData(id);
      emit(ProfileLoadedState(studentData: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(
        ProfileErrorState(
          message:
              'حدث خطأ أثناء تحميل بيانات الطالب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<String?> updateStudentImage(String path) async {
    try {
      log('Starting image update with path: $path');
      final newUrl = await ProfileRepo.updateStudentImage(path);
      log('New image URL: $newUrl');
      return newUrl; // ← just return the URL, screen handles the rest
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
