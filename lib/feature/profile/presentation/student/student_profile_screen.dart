import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/widgets/header_icon_button.dart';
import 'package:saint_paul/feature/profile/data/models/badge_model.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  StudentModel? studentDataLocal;
  StudentModel? studentDataNew;
  String avatarUrlLocal = '';
  String pathLocal = '';
  List<String>? badgesLocal = [];
  int totalTayoLocal = 0;
  bool _isUploadingImage = false;
  Future<void> _handleImageUpload(
    BuildContext context,
    ProfileCubit cubit, {
    required bool fromCamera,
  }) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (pickedImage == null) return;

    final pickedPath = pickedImage.path;

    setState(() {
      pathLocal = pickedPath;
      _isUploadingImage = true;
    });

    pop(context); // close bottom sheet after picking

    try {
      final newUrl = await cubit.updateStudentImage(pickedPath);

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          if (newUrl != null) {
            avatarUrlLocal = newUrl;
            pathLocal = '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        showMyDialoge(
          context,
          'فشل رفع الصورة، حاول مرة أخرى',
          type: DialogType.error,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 1. Load from local storage immediately — no loading flash
    final localData = LocalHelper.getUserData();
    log('Loaded user data from local storage: ${localData?.toJsonLocal()}');
    if (localData != null) {
      studentDataLocal = localData;
      avatarUrlLocal = localData.avatarUrl ?? '';
      badgesLocal = localData.missionBadges ?? [];
      totalTayoLocal = localData.totalTayo ?? 0;
    }
    // 2. Then fetch from Firestore to sync
    context.read<ProfileCubit>().loadStudentData(LocalHelper.getUserId());
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ProfileCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileErrorState) {
            showMyDialoge(context, state.message, type: DialogType.error);
          } else if (state is ProfileLoadedState) {
            final newData = state.studentData;
            if (newData == null) return;
            log('Profile loaded from Firebase: ${newData.toJsonLocal()}');
            // Cache to local storage
            await LocalHelper.setUserData(newData.toJsonLocal());
            LocalHelper.getUserData()
                ?.toJsonLocal(); // to verify it was saved correctly

            // Only update each field if it changed
            setState(() {
              if (newData.totalTayo != studentDataLocal?.totalTayo) {
                totalTayoLocal = newData.totalTayo ?? 0;
              }
              if (newData.avatarUrl != studentDataLocal?.avatarUrl) {
                avatarUrlLocal = newData.avatarUrl ?? '';
              }
              if (newData.missionBadges != studentDataLocal?.missionBadges) {
                badgesLocal = newData.missionBadges ?? [];
              }
              if (newData.name != studentDataLocal?.name) {
                studentDataLocal = newData;
              }
              if (newData.studyLevel != studentDataLocal?.studyLevel) {
                studentDataLocal = newData;
              }
              // Update the reference so future comparisons are against latest data
              studentDataLocal = newData;
            });

            if (state.message != null) {
              showMyDialoge(context, state.message!, type: DialogType.success);
            }
          }
        },

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  32,
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
                child: Column(
                  children: [
                    // Title + logout
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.whiteColor,
                            size: 24,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'الحساب الشخصي',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        HeaderIconButton(
                          svgAsset: AppAssets.logoutSvg,
                          onTap: () => showSignOutDialog(context),
                        ),
                      ],
                    ),
                    const Gap(28),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 3,
                            ),
                            color: AppColors.whiteColor.withValues(alpha: 0.15),
                          ),
                          child: ClipOval(
                            child: pathLocal.isNotEmpty
                                ? // local file path starts with /
                                  Image.file(File(pathLocal), fit: BoxFit.cover)
                                : avatarUrlLocal.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: avatarUrlLocal,
                                    fit: BoxFit.cover,
                                  )
                                : SvgPicture.asset(
                                    AppAssets.profileSvg,
                                    width: 60,
                                    height: 60,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MainButton(
                                            title: 'Upload from Camera',
                                            onPressed: () => _handleImageUpload(
                                              context,
                                              cubit,
                                              fromCamera: true,
                                            ), // ✅
                                          ),
                                          Gap(15),
                                          MainButton(
                                            title: 'Upload from Gallery',
                                            onPressed: () => _handleImageUpload(
                                              context,
                                              cubit,
                                              fromCamera: false,
                                            ), // ✅
                                          ),
                                          Gap(15),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_rounded,
                                color: AppColors.primaryColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(14),
                    // Name inside header
                    Text(
                      studentDataLocal?.name ?? 'اسم الطالب',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      studentDataLocal?.studyLevel ?? '',
                      style: TextStyles.getSize16(
                        color: AppColors.whiteColor.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // ── Stats cards ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.yellowIconColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.yellowIconColor,
                          size: 26,
                        ),
                      ),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مجموع الطايو',
                            style: TextStyles.getSize12(
                              color: AppColors.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '$totalTayoLocal',
                            style: TextStyles.getSize24(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 18, 15, 18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.yellowIconColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.military_tech,
                              color: AppColors.yellowIconColor,
                              size: 28,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'أوسمة',
                            style: TextStyles.getSize18(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              pushTo(
                                context,
                                Routes.badgesScreen,
                                extra: badgesLocal,
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      Gap(15),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: badgesLocal?.length ?? 0,
                          separatorBuilder: (BuildContext context, int index) {
                            return Gap(10);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final badgeName =
                                badgesLocal?[index] ?? 'Badge Name';
                            final badgeImage =
                                badgeModel[badgeName]; // to get badge image from name
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
                                  Container(
                                    height: 80,
                                    width: 80,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellowIconColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      badgeImage ?? AppAssets.tayoKing,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const Gap(12),
                                  Text(
                                    badgeName,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadImage(bool isCamera) async {
    // Pick image locally first
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedImage != null) {
      // Show local image immediately
      setState(() => pathLocal = pickedImage.path);
    }
  }
}
