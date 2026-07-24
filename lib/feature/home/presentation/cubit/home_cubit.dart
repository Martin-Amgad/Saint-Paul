import 'dart:developer';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
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
  var birthdayController = TextEditingController();
  var avatarUrlController = TextEditingController();

  String? selectedYear;
  String? selectedFamily;
  String? selectedResponsibleTeacher = '';

  List<StudentModel> studentsList = [];
  List<TeacherModel> teachers = [];

  var formkey = GlobalKey<FormState>();

  bool get isGoogleMapsLink {
    final text = addressController.text.trim();
    return text.contains("maps.app.goo.gl") ||
        text.contains("google.com/maps") ||
        text.contains("maps.google");
  }

  // this method is used to update a student's information in the database.
  Future<void> updateStudent({
    required StudentModel newStudent,
    StudentModel? oldStudent,
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
    String? groupID,
    int? groupPointsDelta,
  }) async {
    emit(HomeLoadingState());
    try {
      log(
        'Starting student update with newStudent: $newStudent, oldStudent: $oldStudent',
      );
      var res = await HomeRepo.updatStudent(
        newStudent: newStudent,
        oldStudent: oldStudent ?? newStudent,
        tayoNewCategories: tayoNewCategories,
        tayoRemovedCategories: tayoRemovedCategories,
        groupID: groupID,
        groupPointsDelta: groupPointsDelta,
      );
      log('Student update completed with result: $res');

      if (isClosed) return;
      emit(HomeSuccessState(message: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log(" Unexpected error during student update: ${e.toString()}");
      emit(
        HomeErrorState(
          message:
              'حدث خطأ أثناء تحديث بيانات المخدوم. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // this method
  Future<void> updateStudentTakenAt(
    StudentModel student, {
    List<String>? tayoNewCategories,
    List<String>? tayoRemovedCategories,
  }) async {
    try {
      await HomeRepo.updatStudentTakenAt(student);

      if (isClosed) return;
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

  // this method
  void getStudentTayoDetails(StudentModel student) async {
    emit(HomeLoadingState());
    try {
      var res = await HomeRepo.getStudentTayoDetails(student);
      if (res != null) {
        // log('Student details retrieved successfully: $res');
        if (isClosed) return;
        emit(HomeTayoLoadSuccessState(tayo: res));
      } else {
        log('No student details found for the given student.');
      }
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    }
  }

  // this method
  void createStudent(StudentModel student) async {
    emit(HomeLoadingState());
    String? res;
    try {
      res = await HomeRepo.createStudent(student);

      if (isClosed) return;
      emit(HomeSuccessState(message: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: res ?? e.toString()));
    }
  }

  // this method
  void loadStudentControllers(StudentModel? student) {
    log(
      'Loading student controllers with student teacher: ${student?.responsibleTeacher}',
    );
    nameController.text = (student?.name ?? '').trim();
    fatherPhoneController.text = (student?.fatherPhone ?? '').trim();
    motherPhoneController.text = (student?.motherPhone ?? '').trim();
    personalPhoneController.text = (student?.personalPhone ?? '').trim();
    housePhoneController.text = (student?.housePhone ?? '').trim();
    addressController.text = (student?.address ?? '').trim();
    selectedFamily = student?.family;
    selectedYear = student?.studyLevel;
    selectedResponsibleTeacher = student?.responsibleTeacher;
    birthdayController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(student?.birthday ?? DateTime.now());
    avatarUrlController.text = student?.avatarUrl ?? '';
  }

  // this method
  Future<void> loadStudentYear(String? id) async {
    emit(HomeLoadingState());
    try {
      final res = await HomeRepo.loadStudentYear(id);

      if (isClosed) return;
      emit(StudentYearLoaded(year: res ?? ''));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    }
  }

  // this method
  void loadStudentData(String? id) async {
    emit(HomeLoadingState());
    try {
      StudentModel? res = await HomeRepo.loadStudentData(id);

      if (isClosed) return;
      emit(HomeStudentLoadedState(studentData: res));
    } on Exception catch (e) {
      log(e.toString());
      emit(
        HomeErrorState(
          message:
              'حدث خطأ أثناء تحميل بيانات الطالب. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // this method
  Future<String?> uploadBadgeImageToCloudinary(
    String path,
    String badgeName,
  ) async {
    try {
      log('Starting image update with path: $path');
      final newUrl = await HomeRepo.uploadBadgeImageToCloudinary(
        badgeName,
        path,
      );

      log('New image URL: $newUrl');
      return newUrl; // ← just return the URL, screen handles the rest
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // this method
  Future<void> createChurchFamilyBadge(String badgeName, String url) async {
    try {
      var currentBadges = await HomeRepo.getCurrentChurchFamilyBadges();
      log(
        ' /////////////////////////////// Current badges in config: $currentBadges',
      );
      if (currentBadges.any((badge) => badge.name == badgeName)) {
        log('Badge with name "$badgeName" already exists in config.');
        emit(
          HomeErrorState(
            message:
                'هناك شارة موجودة بالفعل بهذا الاسم. الرجاء اختيار اسم آخر.',
          ),
        );
        return;
      }
      await HomeRepo.createBadge(badgeName, url);

      if (isClosed) return;
      emit(HomeBadgeCreationSuccessState());
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log(e.toString());
      emit(
        HomeErrorState(
          message: 'حدث خطأ أثناء إضافة الشارة. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // this method
  Future<void> addChurchToAllDocs(String churchName) async {
    try {
      log(
        'Adding church "$churchName" to all documents in the Students collection',
      );
      await HomeRepo.addChurchToAllDocs(churchName);

      if (isClosed) return;
      emit(HomeSuccessState(message: 'تم إضافة اسم الكنيسة بنجاح.'));
    } on Exception catch (e) {
      log(e.toString());
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log(e.toString());
      emit(
        HomeErrorState(
          message: 'حدث خطأ أثناء إضافة اسم الكنيسة. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // this method
  Future<void> importStudentsFromExcel(Uint8List bytes) async {
    emit(HomeLoadingState());
    try {
      await HomeRepo.importStudentsFromExcel(bytes);
      emit(HomeSuccessState(message: "تم اضافة الطلاب بنجاح."));
    } catch (e) {
      emit(
        HomeErrorState(
          message: "حدث خطأ أثناء استيراد الطلاب. الرجاء المحاولة مرة أخرى.",
        ),
      );
    }
  }

  // this method
  Future<void> downloadExcelTemplate() async {
    try {
      final data = await rootBundle.load('assets/files/student_template.xlsx');
      final bytes = data.buffer.asUint8List();

      final path = await FilePicker.saveFile(
        dialogTitle: 'حفظ نموذج الملف',
        fileName: 'student_template.xlsx',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (path != null) {
        emit(
          HomeExcelTemplateDownloadSuccessState(message: "تم حفظ الملف بنجاح."),
        );
      } else {
        // user cancelled the dialog — you may want to just do nothing here
      }
    } catch (e) {
      log('Error while saving the file: ${e.toString()}');
      emit(HomeErrorState(message: "حدث خطأ أثناء حفظ الملف."));
    }
  }

  Future<void> getChurchTeachers(String churchName) async {
    try {
      teachers = await HomeRepo.getChurchTeachers(churchName);
      emit(HomeTeachersLoadedState(teachers: teachers));
    } on Exception catch (e) {
      log('Error while loading church teachers: ${e.toString()}');
      emit(HomeErrorState(message: e.toString()));
    } catch (e) {
      log('Unexpected error: ${e.toString()}');
      emit(
        HomeErrorState(
          message:
              'حدث خطأ أثناء تحميل بيانات الخدام. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }
}
