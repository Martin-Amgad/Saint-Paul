import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import '../constants/app_assets.dart';
import '../utils/colors.dart';

enum DialogType { success, error, warning }

showMyDialoge(
  BuildContext context,
  String message, {
  DialogType type = DialogType.error,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: type == DialogType.error
          ? Colors.red
          : type == DialogType.warning
          ? AppColors.accentColor
          : AppColors.primaryDarkColor,
      content: Text(message),
    ),
  );
}

/// Shows a loading dialog.
///
/// * [context]: The build context.
showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: SizedBox(height: 150, child: Lottie.asset(AppAssets.loadingJson)),
    ),
  );
}

void showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'تاكيد تسجيل الخروج',
        style: TextStyles.getSize18(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'هل أنت متأكد من تسجيل الخروج؟',
        style: TextStyles.getSize16(),
      ),
      actions: [
        Row(
          children: [
            MainButton(
              title: 'تسجيل الخروج',
              width: 150,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                LocalHelper.setIsNewUser(true);

                pushToBase(context, Routes.welcome);
              },
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.secondaryColor.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Text(
                'الغاء',
                style: TextStyles.getSize16(color: AppColors.primaryDarkColor),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
