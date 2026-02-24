import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/feature/home/data/repo/home_repo.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(Homeinit());
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

  //   void getHomeData() async {
  //     emit(HomeLoadingState());

  //     try {
  //       var res = await Future.wait([
  //         HomeRepo.getSlider(),
  //         HomeRepo.getBestSellers(),
  //         HomeRepo.getNewArrivals(),
  //         HomeRepo.getAllBooks(),
  //       ]);

  //       sliders = (res[0] as SliderResponse).data?.sliders ?? [];
  //       BestSellers = (res[1] as BookListRsponse).data?.products ?? [];
  //       NewArrivals = (res[2] as BookListRsponse).data?.products ?? [];
  //       AllBooks = (res[3] as BookListRsponse).data?.products ?? [];
  //       emit(HomeSuccesState());
  //     } on Exception catch (e) {
  //       log(e.toString());
  //       emit(HomeErrorState(message: e.toString()));
  //     }
  //   }
  void updateStudent(
    StudentModel student, {
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  }) async {
    emit(HomeLoadingState());
    try {
      var res = await HomeRepo.updatStudent(
        student,
        tayoNewCategories,
        tayoRemovedCategories,
      );
      emit(HomeSuccessState(message: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log(e.toString());
      emit(
        HomeErrorState(
          message:
              'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  void updateStudentTakenAt(
    StudentModel student, {
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  }) async {
    try {
      await HomeRepo.updatStudentTakenAt(student);
      emit(HomeSuccessStateForTakenAt());
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log(e.toString());
      emit(
        HomeErrorState(
          message:
              'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  void getStudentTayoDetails(StudentModel student) async {
    emit(HomeLoadingState());
    try {
      var res = await HomeRepo.getStudentTayoDetails(student);
      if (res != null) {
        log('Student details retrieved successfully: $res');
        emit(HomeTayoLoadSuccessState(tayo: res));
      } else {
        log('No student details found for the given student.');
      }
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    }
  }

  void createStudent(StudentModel student) async {
    emit(HomeLoadingState());
    String? res;
    try {
      res = await HomeRepo.createStudent(student);
      emit(HomeSuccessState(message: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: res ?? e.toString()));
    }
  }

  void loadStudentControllers(StudentModel? student) {
    nameController.text = student?.name ?? '';
    fatherPhoneController.text = student?.fatherPhone ?? '';
    motherPhoneController.text = student?.motherPhone ?? '';
    personalPhoneController.text = student?.personalPhone ?? '';
    housePhoneController.text = student?.housePhone ?? '';
    addressController.text = student?.address ?? '';
    studyLevelController.text = student?.studyLevel ?? '';
    birthdayController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(student?.birthday ?? DateTime.now());
  }

  Future<void> loadStudentYear(String? id) async {
    emit(HomeLoadingState());
    try {
      final res = await HomeRepo.loadStudentYear(id);
      emit(StudentYearLoaded(year: res ?? 'ثالثة اعدادي'));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    }
  }
}
