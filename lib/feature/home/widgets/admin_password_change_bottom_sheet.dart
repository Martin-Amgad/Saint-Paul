import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class AdminPasswordChangeBottomSheet extends StatefulWidget {
  const AdminPasswordChangeBottomSheet({super.key});

  @override
  State<AdminPasswordChangeBottomSheet> createState() =>
      _AdminPasswordChangeBottomSheetState();
}

class _AdminPasswordChangeBottomSheetState
    extends State<AdminPasswordChangeBottomSheet> {
  var newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                'تغيير كلمة المرور',
                style: TextStyles.getSize18(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(20),
          CustomTextField(
            controller: newPasswordController,
            hintText: 'كلمة المرور الجديدة',
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryColor,
            ),
            isPassword: true,
          ),

          const Gap(20),
          MainButton(
            title: 'تغيير كلمة المرور',
            onPressed: () async {
              log('Button pressed');
              await FirebaseProvider.updateTeacher(
                TeacherModel(
                  uid: '28W6AI0V3SGxJI7qHY73',
                  adminPin: newPasswordController.text.trim(),
                ),
              );
              log('Password updated in Firestore');
              newPasswordController.clear();
              pop(context);
            },
          ),
        ],
      ),
    );
  }
}
