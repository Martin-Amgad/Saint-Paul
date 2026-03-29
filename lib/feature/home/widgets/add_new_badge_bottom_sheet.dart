import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/form_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';

class AddNewBadgeSheet extends StatefulWidget {
  const AddNewBadgeSheet({super.key});

  @override
  State<AddNewBadgeSheet> createState() => _AddNewBadgeSheetState();
}

class _AddNewBadgeSheetState extends State<AddNewBadgeSheet> {
  String _localPath = '';
  String _uploadedUrl = '';
  bool _isUploading = false;
  var newBadgeNameController = TextEditingController();

  Future<void> _pickAndUpload(HomeCubit cubit) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (picked == null) return;

    setState(() {
      _localPath = picked.path;
      _isUploading = true;
    });

    try {
      final url = await cubit.uploadBadgeImageToCloudinary(
        picked.path,
        newBadgeNameController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isUploading = false;
          if (url != null) {
            _uploadedUrl = url;
            _localPath = '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        showMyDialoge(
          context,
          'فشل رفع الصورة، حاول مرة أخرى',
          type: DialogType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  AppAssets.addFilledBadgeIcon,
                  width: 20,
                  height: 20,
                  color: AppColors.primaryColor,
                ),
              ),
              const Gap(12),
              Text(
                'إضافة وسام جديد',
                style: TextStyles.getSize18(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const Gap(24),

          // ── Image picker ──────────────────────────────────────────
          GestureDetector(
            onTap: _isUploading ? null : () => _pickAndUpload(cubit),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.09),
                  width: 3,
                ),
                color: AppColors.primaryColor.withValues(alpha: 0.15),
              ),
              child: ClipOval(
                child: _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : _localPath.isNotEmpty
                    ? Image.file(File(_localPath), fit: BoxFit.cover)
                    : _uploadedUrl.isNotEmpty
                    ? Image.network(_uploadedUrl, fit: BoxFit.cover)
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
              ),
            ),
          ),

          const Gap(20),

          // ── Name field ────────────────────────────────────────────
          CustomFormField(
            label: 'اسم الوسام',
            icon: Icons.workspace_premium_outlined,

            child: CustomTextField(
              controller: newBadgeNameController,
              hintText: 'أدخل اسم الوسام',
            ),
          ),

          const Gap(24),

          // ── Confirm button ────────────────────────────────────────
          MainButton(
            title: 'إضافة الوسام',
            onPressed: _isUploading
                ? () {}
                : () async {
                    if (_uploadedUrl.isEmpty) {
                      showMyDialoge(
                        context,
                        'يرجى اختيار صورة للوسام',
                        type: DialogType.error,
                      );
                      return;
                    }
                    if (newBadgeNameController.text.trim().isEmpty) {
                      showMyDialoge(
                        context,
                        'يرجى إدخال اسم الوسام',
                        type: DialogType.error,
                      );
                      return;
                    }
                    await cubit.createBadgeInConfig(
                      newBadgeNameController.text.trim(),
                      _uploadedUrl,
                    );

                    pop(context);
                  },
          ),
        ],
      ),
    );
  }
}
