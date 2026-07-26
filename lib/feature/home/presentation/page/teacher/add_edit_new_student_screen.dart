import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide FormField;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/components/inputs/Custom_form_field.dart';
import 'package:saint_paul/feature/auth/data/models/school_years_model.dart';
import 'package:saint_paul/feature/home/data/repo/home_repo.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';
import 'package:url_launcher/url_launcher.dart';

class AddEditNewStudentScreen extends StatefulWidget {
  const AddEditNewStudentScreen({super.key, this.student});
  final StudentModel? student;

  @override
  State<AddEditNewStudentScreen> createState() =>
      _AddEditNewStudentScreenState();
}

class _AddEditNewStudentScreenState extends State<AddEditNewStudentScreen> {
  final List<BadgeModel> availableBadges = [];
  final Map<String, String> myBadges = {};
  List<BadgeModel> allBadges = [];
  final GlobalKey<FormFieldState<String>> _badgeDropdownKey =
      GlobalKey<FormFieldState<String>>();
  final List<String> families = SchoolYearsModel.getFamilies();
  List<String> items = SchoolYearsModel.allYears.values
      .expand((list) => list)
      .toList();

  List<String?> teachersNames = LocalHelper.getTeacherNames() ?? [];
  List<TeacherModel> teachers = [];
  DateTime? pickedDate;
  @override
  void initState() {
    var cubit = context.read<HomeCubit>();
    cubit.loadStudentControllers(widget.student);
    cubit.getChurchTeachers(LocalHelper.getUserChurchName() ?? '');

    if (widget.student != null) {
      myBadges.addAll(widget.student!.myBadges ?? {});
    }
    getAllTeacher();
    getAllBadges();
    super.initState();
  }

  Future<void> getAllTeacher() async {
    teachers = await FirebaseProvider.getChurchTeachers(
      LocalHelper.getUserChurchName() ?? '',
    );
    LocalHelper.setTeacherNames(
      teachers.map((teacher) => teacher.name ?? '').toList(),
    );
  }

  Future<void> getAllBadges() async {
    final fetchedBadges = await FirebaseProvider.getChurchFamilyBadges(
      LocalHelper.getUserChurchName(),
      LocalHelper.getUserFamily(),
    );

    // Keep a single badge per ID to avoid duplicate dropdown values.
    final uniqueById = <String, BadgeModel>{};
    for (final badge in fetchedBadges) {
      final badgeId = badge.bId;
      if (badgeId == null || badgeId.isEmpty) continue;
      uniqueById[badgeId] = badge;
    }
    allBadges = uniqueById.values.toList();

    if (mounted) {
      setState(() {
        availableBadges.clear();
        for (var badge in allBadges) {
          if (!myBadges.containsKey(badge.bId)) {
            availableBadges.add(badge);
          }
        }
      });
    }
  }

  BadgeModel? _badgeById(String badgeId) {
    for (final badge in allBadges) {
      if (badge.bId == badgeId) {
        return badge;
      }
    }
    return null;
  }

  String _badgeLabel(String badgeId) {
    final badgeName = _badgeById(badgeId)?.name;
    if (badgeName == null || badgeName.trim().isEmpty) {
      return badgeId;
    }
    return badgeName;
  }

  Future<void> importStudentsFromExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null) return;

    final Uint8List bytes = result.files.single.bytes!;
    context.read<HomeCubit>().importStudentsFromExcel(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final isLink = cubit.isGoogleMapsLink;
    final FocusNode addressFocusNode = FocusNode();
    final selectedTeacher =
        teachersNames.contains(cubit.selectedResponsibleTeacher)
        ? cubit.selectedResponsibleTeacher
        : null;
    log(
      'build: selectedResponsibleTeacher = ${cubit.selectedResponsibleTeacher}',
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: MainButton(
            title: 'حفظ',
            onPressed: () async {
              var teacherId = teachers
                  .firstWhere(
                    (teacher) =>
                        teacher.name == cubit.selectedResponsibleTeacher,
                    orElse: () => TeacherModel(),
                  )
                  .uid;
              // log the new badges
              log('Current badges: ${myBadges.keys.join(', ')}');
              if (cubit.formkey.currentState?.validate() ?? false) {
                if (widget.student != null) {
                  cubit.updateStudent(
                    newStudent: widget.student!.copyWith(
                      name: cubit.nameController.text.trim(),
                      fatherPhone: cubit.fatherPhoneController.text.trim(),
                      motherPhone: cubit.motherPhoneController.text.trim(),
                      personalPhone: cubit.personalPhoneController.text.trim(),
                      housePhone: cubit.housePhoneController.text.trim(),
                      address: cubit.addressController.text.trim(),
                      birthday: pickedDate,
                      studyLevel: cubit.selectedYear,
                      responsibleTeacher: cubit.selectedResponsibleTeacher,
                      avatarUrl: cubit.avatarUrlController.text.trim(),
                      myBadges: Map<String, String>.from(myBadges),
                      family: cubit.selectedFamily,
                      church: LocalHelper.getUserChurchName(),
                    ),
                    oldStudent: widget.student!,
                    teacherId: teacherId,
                    studentId: widget.student!.uid,
                  );
                } else {
                  cubit.createStudent(
                    StudentModel(
                      name: cubit.nameController.text.trim(),
                      fatherPhone: cubit.fatherPhoneController.text.trim(),
                      motherPhone: cubit.motherPhoneController.text.trim(),
                      personalPhone: cubit.personalPhoneController.text.trim(),
                      housePhone: cubit.housePhoneController.text.trim(),
                      address: cubit.addressController.text.trim(),
                      birthday: pickedDate,
                      avatarUrl: cubit.avatarUrlController.text.trim(),
                      studyLevel: cubit.selectedYear,
                      responsibleTeacher: cubit.selectedResponsibleTeacher,
                      myBadges: Map<String, String>.from(myBadges),
                      family: cubit.selectedFamily,
                      church: LocalHelper.getUserChurchName(),
                    ),
                    teacherId: teacherId,
                  );
                }
                // cubit.addStudentIdToTeacher(
                //   teacherId: cubit.selectedResponsibleTeacher,
                //   studentId: widget.student?.uid ?? '',
                // );
              }
            },
          ),
        ),
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingState) {
            showLoadingDialog(context);
          } else if (state is HomeSuccessState) {
            pop(context);

            showMyDialoge(
              context,
              widget.student == null ? 'تمت الاضافة بنجاح' : 'تم التعديل بنجاح',
              type: DialogType.success,
            );
            pop(context);
          } else if (state is HomeErrorState) {
            pop(context);
            showMyDialoge(context, state.message, type: DialogType.error);
          }
        },
        builder: (context, state) {
          log('Current state: $state');

          items = SchoolYearsModel.allYears[cubit.selectedFamily] ?? [];
          if (state is HomeTeachersLoadedState) {
            log(
              'Loaded teachers: ${state.teachers.map((t) => t.name).join(', ')}',
            );

            teachersNames = cubit.teachers
                .where((teacher) {
                  if (cubit.selectedYear == null) return true;
                  return teacher.assignedStudyLevel == cubit.selectedYear;
                })
                .map((teacher) => teacher.name)
                .toList();

            log('Teachers: $teachersNames');
            log(
              'Matches: ${teachersNames.where((e) => e == cubit.selectedResponsibleTeacher).length}',
            );
          }
          return Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 15,
                  20,
                  24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CustomButton(),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student == null
                              ? 'اضافة مخدوم جديد'
                              : 'تعديل بيانات المخدوم',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'املأ البيانات التالية',
                          style: TextStyles.getSize12(
                            color: AppColors.whiteColor.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),

                    // Upload Excel Button
                    CustomButton(
                      icon: Icons.upload_file_outlined,
                      onTap: () async {
                        // await importStudentsFromExcel();
                        pushTo(context, Routes.studentsExcelUploadScreen);
                      },
                    ),
                  ],
                ),
              ),

              // ── Form ──────────────────────────────────────────────────
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Form(
                      key: cubit.formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name field
                          CustomFormField(
                            label: 'اسم المخدوم',
                            icon: Icons.person_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل اسم المخدوم',
                              controller: cubit.nameController,
                              validator: (p0) {
                                if (p0 == null || p0.isEmpty) {
                                  return 'ارجوك ادخل اسم المخدوم';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // family dropdown
                          CustomFormField(
                            label: 'الأسرة',
                            icon: Icons.group_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              initialValue: cubit.selectedFamily,
                              hint: Text(
                                'الأسرة',
                                style: TextStyles.getSize16(
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(fontFamily: 'Cairo'),
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryColor,
                              ),
                              dropdownColor: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              style: TextStyles.getSize16(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 3,
                                ),
                              ),
                              selectedItemBuilder: (context) {
                                return families.map((item) {
                                  return Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: families.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.whiteColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  cubit.selectedFamily = value;
                                  items =
                                      SchoolYearsModel.allYears[value] ?? [];
                                  cubit.selectedYear = null;
                                });
                              },
                            ),
                          ),
                          const Gap(15),

                          // study level dropdown
                          CustomFormField(
                            label: " المستوى الدراسي",
                            icon: Icons.school_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              initialValue: cubit.selectedYear,
                              hint: Text(
                                " المستوى الدراسي",
                                style: TextStyles.getSize16(
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(fontFamily: 'Cairo'),
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryColor,
                              ),
                              dropdownColor: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              style: TextStyles.getSize16(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 3,
                                ),
                              ),
                              selectedItemBuilder: (context) {
                                return items.map((item) {
                                  return Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: items.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyles.getSize16(
                                      color: AppColors.whiteColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  cubit.selectedYear = value;
                                  // recompute which teachers are valid for the newly selected year
                                  final validTeachers = cubit.teachers
                                      .where(
                                        (teacher) =>
                                            teacher.assignedStudyLevel == value,
                                      )
                                      .map((teacher) => teacher.name)
                                      .toList();

                                  // only clear if the currently selected teacher doesn't belong to this year
                                  if (!validTeachers.contains(
                                    cubit.selectedResponsibleTeacher,
                                  )) {
                                    cubit.selectedResponsibleTeacher = null;
                                  }
                                  // cubit.
                                });
                              },
                            ),
                          ),
                          const Gap(15),

                          // birthday field
                          CustomFormField(
                            label: 'تاريخ الميلاد',
                            icon: Icons.cake_rounded,
                            child: CustomTextField(
                              controller: cubit.birthdayController,
                              readOnly: true,
                              hintText: 'تاريخ الميلاد',
                              onTap: () async {
                                var selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365 * 100),
                                  ),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  pickedDate = selectedDate;
                                  cubit.birthdayController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDate);
                                }
                              },
                              suffixIcon: Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.primaryColor,
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء ادخال تاريخ الميلاد';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // responsible teacher field
                          CustomFormField(
                            label: " الخادم المسئول",
                            icon: Icons.person_rounded,
                            child: DropdownButtonFormField<String>(
                              isDense: false,
                              initialValue: selectedTeacher,
                              hint: Text(
                                'اختر الخادم المسئول',
                                style: TextStyles.getSize16(
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(fontFamily: 'Cairo'),
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryColor,
                              ),
                              dropdownColor: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              style: TextStyles.getSize16(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 3,
                                ),
                              ),
                              selectedItemBuilder: (context) {
                                return teachersNames.map((item) {
                                  return Text(
                                    item ?? '',
                                    style: TextStyles.getSize16(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  );
                                }).toList();
                              },

                              items: teachersNames.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item ?? '',
                                    style: TextStyles.getSize16(
                                      color: AppColors.whiteColor,
                                      fontWeight: FontWeight.w500,
                                    ).copyWith(fontFamily: 'Cairo'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  cubit.selectedResponsibleTeacher = value;
                                  // cubit.
                                });
                              },
                            ),
                          ),

                          const Gap(15),

                          // address field
                          CustomFormField(
                            label: 'العنوان',
                            icon: Icons.location_on_rounded,
                            child: CustomTextField(
                              controller: cubit.addressController,
                              readOnly: isLink,
                              hintText: 'ادخل العنوان',
                              focusNode: addressFocusNode,
                              onTap: isLink
                                  ? () => launchUrl(
                                      Uri.parse(cubit.addressController.text),
                                    )
                                  : null,

                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    cubit.addressController.clear();
                                  });

                                  FocusScope.of(
                                    context,
                                  ).requestFocus(addressFocusNode);
                                  // cubit.emit(AddressChanged());
                                },
                              ),
                            ),
                          ),
                          const Gap(15),

                          // student phone field
                          CustomFormField(
                            label: 'تليفون المخدوم',
                            icon: Icons.smartphone_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل تليفون المخدوم',
                              controller: cubit.personalPhoneController,
                              isPhone: true,
                              validator: (p0) {
                                final value = (p0 ?? '').trim();
                                if (value.isNotEmpty &&
                                    !AppRegex.isEgyptianPhoneValid(value)) {
                                  return 'رجاء ادخل رقم هاتف صالحا';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // father phone field
                          CustomFormField(
                            label: 'تليفون الأب',
                            icon: Icons.phone_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل تليفون الأب',
                              controller: cubit.fatherPhoneController,
                              isPhone: true,
                              validator: (p0) {
                                if (p0 == null || p0.isEmpty)
                                  return null; // allow empty
                                if (!AppRegex.isEgyptianPhoneValid(p0))
                                  return 'رجاء ادخل رقم هاتف صالحا';
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // mother phone field
                          CustomFormField(
                            label: 'تليفون الأم',
                            icon: Icons.phone_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل تليفون الأم',
                              controller: cubit.motherPhoneController,
                              isPhone: true,
                              validator: (p0) {
                                final value = (p0 ?? '').trim();
                                if (value.isNotEmpty &&
                                    !AppRegex.isEgyptianPhoneValid(value)) {
                                  return 'رجاء ادخل رقم هاتف صالحا';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // house phone field
                          CustomFormField(
                            label: 'تليفون المنزل',
                            icon: Icons.home_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل تليفون المنزل',
                              controller: cubit.housePhoneController,
                              isLandline: true,
                              validator: (p0) {
                                final value = (p0 ?? '').trim();
                                if (value.isNotEmpty &&
                                    !AppRegex.isEgyptianLandlineValid(value)) {
                                  return 'رجاء ادخل رقم هاتف صالحا';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Gap(15),

                          // avatar url field
                          CustomFormField(
                            label: 'صورة المخدوم (رابط)',
                            icon: Icons.home_rounded,
                            child: CustomTextField(
                              hintText: 'ادخل رابط صورة المخدوم',
                              controller: cubit.avatarUrlController,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  cubit.avatarUrlController.clear();
                                  setState(() {
                                    cubit.avatarUrlController.text = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (availableBadges.isNotEmpty) ...[
                            const Gap(15),

                            // badge dropdown
                            CustomFormField(
                              label: ' أضافة وسام',
                              icon: Icons.emoji_events_rounded,
                              child: DropdownButtonFormField<String>(
                                key: _badgeDropdownKey,
                                isDense: false,
                                initialValue: null,
                                hint: Text(
                                  ' أضافة وسام',
                                  style: TextStyles.getSize16(
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w500,
                                  ).copyWith(fontFamily: 'Cairo'),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primaryColor,
                                ),
                                dropdownColor: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(15),
                                style: TextStyles.getSize16(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 3,
                                  ),
                                ),
                                selectedItemBuilder: (context) {
                                  return availableBadges.map((item) {
                                    return Text(
                                      item.name ?? '',
                                      style: TextStyles.getSize16(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ).copyWith(fontFamily: 'Cairo'),
                                    );
                                  }).toList();
                                },

                                items: availableBadges.map((badge) {
                                  return DropdownMenuItem(
                                    value: badge.bId,
                                    child: Text(
                                      badge.name ?? '',
                                      style: TextStyles.getSize16(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.w500,
                                      ).copyWith(fontFamily: 'Cairo'),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  final selectedBadge = _badgeById(value);
                                  if (selectedBadge == null) return;
                                  final badgeId = selectedBadge.bId;
                                  if (badgeId == null || badgeId.isEmpty)
                                    return;

                                  setState(() {
                                    myBadges[badgeId] = selectedBadge.url ?? '';
                                    availableBadges.removeWhere(
                                      (badge) => badge.bId == badgeId,
                                    );
                                  });
                                  _badgeDropdownKey.currentState?.reset();
                                },
                              ),
                            ),
                          ],
                          const Gap(15),

                          // badges list
                          CustomFormField(
                            label: 'الأوسمة',
                            pngPicture: AppAssets.addFilledBadgeIcon,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.22,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: myBadges.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return Gap(10);
                                    },
                                itemBuilder: (BuildContext context, int index) {
                                  final badgeId = myBadges.keys.toList()[index];
                                  final badgeImage = myBadges[badgeId];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.15,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.3,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .darkYellowIconColor
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child:
                                                  badgeImage != null &&
                                                      badgeImage.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: badgeImage,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color: AppColors
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      size: 32,
                                                    ),
                                            ),
                                            Positioned(
                                              top: 2,
                                              left: 2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  final removedBadge =
                                                      _badgeById(badgeId);
                                                  setState(() {
                                                    myBadges.remove(badgeId);
                                                    if (removedBadge != null &&
                                                        !availableBadges.any(
                                                          (badge) =>
                                                              badge.bId ==
                                                              removedBadge.bId,
                                                        )) {
                                                      availableBadges.add(
                                                        removedBadge,
                                                      );
                                                    }
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  color: AppColors.primaryColor
                                                      .withValues(alpha: 0.7),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(5),
                                        Text(
                                          _badgeLabel(badgeId),
                                          style: TextStyles.getSize16(
                                            color: AppColors.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
