import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/components/inputs/Custom_form_field.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

class AddEditNewStudentScreen extends StatefulWidget {
  const AddEditNewStudentScreen({super.key, this.student});
  final StudentModel? student;

  @override
  State<AddEditNewStudentScreen> createState() =>
      _AddEditNewStudentScreenState();
}

class _AddEditNewStudentScreenState extends State<AddEditNewStudentScreen> {
  final List<String> items = ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'];
  final List<BadgeModel> availableBadges = [];
  final Map<String, String> myBadges = {};
  List<BadgeModel> allBadges = [];
  final GlobalKey<FormFieldState<String>> _badgeDropdownKey =
      GlobalKey<FormFieldState<String>>();

  DateTime? pickedDate;
  @override
  void initState() {
    context.read<HomeCubit>().loadStudentControllers(widget.student);

    if (widget.student != null) {
      myBadges.addAll(widget.student!.myBadges ?? {});
    }
    getAllBadges();
    super.initState();
  }

  Future<void> getAllBadges() async {
    final fetchedBadges = await FirebaseProvider.getBadgesFor(
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: MainButton(
            title: 'حفظ',
            onPressed: () async {
              log('Save button pressed. Validating form...');
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
                      studyLevel: cubit.selectedValue,
                      birthday: pickedDate,
                      responsibleTeacher: cubit
                          .responsibleTeacherController
                          .text
                          .trim(),
                      myBadges: Map<String, String>.from(myBadges),
                    ),
                    oldStudent: widget.student!,
                  );
                  return;
                }
                cubit.createStudent(
                  StudentModel(
                    uid: LocalHelper.getUserId() ?? '',
                    name: cubit.nameController.text.trim(),
                    fatherPhone: cubit.fatherPhoneController.text.trim(),
                    motherPhone: cubit.motherPhoneController.text.trim(),
                    personalPhone: cubit.personalPhoneController.text.trim(),
                    housePhone: cubit.housePhoneController.text.trim(),
                    address: cubit.addressController.text.trim(),
                    studyLevel: cubit.selectedValue,
                    birthday: pickedDate,
                    responsibleTeacher: cubit.responsibleTeacherController.text
                        .trim(),
                    myBadges: Map<String, String>.from(myBadges),
                  ),
                );
              }
            },
          ),
        ),
      ),
      body: BlocListener<HomeCubit, HomeState>(
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
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
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
                  CustomBackButton(),
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

                        const Gap(16),
                        CustomFormField(
                          label: 'المستوى الدراسي',
                          icon: Icons.school_rounded,
                          child: DropdownButtonFormField<String>(
                            isDense: false,
                            value:
                                cubit.selectedValue != null &&
                                    items.contains(cubit.selectedValue)
                                ? cubit.selectedValue
                                : null,
                            hint: Text(
                              'المستوى الدراسي',
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
                            borderRadius: BorderRadius.circular(16),
                            style: TextStyles.getSize16(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
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
                              setState(() => cubit.selectedValue = value);
                            },
                          ),
                        ),
                        const Gap(16),
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
                        const Gap(16),
                        CustomFormField(
                          label: ' الخادم المسئول',
                          icon: Icons.supervisor_account_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل الخادم المسئول',
                            controller: cubit.responsibleTeacherController,
                          ),
                        ),
                        const Gap(16),
                        CustomFormField(
                          label: 'العنوان',
                          icon: Icons.location_on_rounded,
                          child: CustomTextField(
                            hintText: 'ادخل العنوان',
                            controller: cubit.addressController,
                            validator: (p0) {
                              if (p0 == null || p0.isEmpty) {
                                cubit.addressController.text = '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(16),
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
                        const Gap(16),
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
                        const Gap(16),
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

                        const Gap(16),
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
                        const Gap(16),
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
                          const Gap(16),

                          CustomFormField(
                            label: ' أضافة وسام',
                            icon: Icons.emoji_events_rounded,
                            child: DropdownButtonFormField<String>(
                              key: _badgeDropdownKey,
                              isDense: false,
                              value: null,
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
                              borderRadius: BorderRadius.circular(16),
                              style: TextStyles.getSize16(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
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
                                if (badgeId == null || badgeId.isEmpty) return;

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

                        const Gap(16),
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
                                                        .withValues(alpha: 0.3),
                                                    size: 32,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 2,
                                            left: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                final removedBadge = _badgeById(
                                                  badgeId,
                                                );
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
        ),
      ),
    );
  }
}
