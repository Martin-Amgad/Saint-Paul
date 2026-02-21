import 'dart:developer';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/feature/home/data/repo/home_repo.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(Homeinit());

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
    StudentModel student,
    List<String> tayoNewCategories,
    List<String> tayoRemovedCategories,
  ) async {
    emit(HomeLoadingState());
    try {
      // Call the updateStudent method from FirebaseProvider
      await HomeRepo.updatStudent(
        student,
        tayoNewCategories,
        tayoRemovedCategories,
      );
      emit(HomeSuccessState());
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
}
