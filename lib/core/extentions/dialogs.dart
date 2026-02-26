import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import '../constants/app_assets.dart';
import '../utils/colors.dart';

enum DialogType { success, error, warning }

void showMyDialoge(
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

void showLoadingDialog(BuildContext context) {
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
        'تأكيد تسجيل الخروج',
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
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
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

void sureToDeleteMissionDialog(
  BuildContext context, {
  String? title,
  String? content,
  String? mainButtonText,
  Function()? mainButtonOnConfirm,
  String? secondaryButtonText,
  Function()? secondaryButtonOnConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.accentColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.accentColor,
          size: 30,
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? 'هل تريد الرجوع؟',
            textAlign: TextAlign.center,
            style: TextStyles.getSize18(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(8),
          Text(
            content ?? 'سيتم فقدان التغييرات غير المحفوظة إذا رجعت الآن.',
            style: TextStyles.getSize16(
              color: AppColors.accentColor.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            MainButton(
              title: mainButtonText ?? 'الغاء',
              width: 125,

              onPressed:
                  mainButtonOnConfirm ??
                  () {
                    pop(context);
                  },
            ),
            Spacer(),
            MainButton(
              title: secondaryButtonText ?? 'الرجوع',
              width: 125,
              textColor: AppColors.primaryColor,
              bgcolor: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: 14,
              hasShadow: false,
              borderColor: AppColors.primaryColor.withValues(alpha: 0.2),
              onPressed:
                  secondaryButtonOnConfirm ??
                  () {
                    pop(context);
                    pop(context);
                  },
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> showChangesNotSavedDialog(
  BuildContext context, {
  String? title,
  String? content,
  String? mainButtonText,
  Function()? mainButtonOnConfirm,
  String? secondaryButtonText,
  Function()? secondaryButtonOnConfirm,
  Map<String, dynamic>? tayo,
  Map<String, dynamic>? oldTayo,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(5, 20, 5, 12),
      title: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.accentColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.accentColor,
          size: 30,
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? 'هل تريد الرجوع؟',
            textAlign: TextAlign.center,
            style: TextStyles.getSize18(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(8),
          Text(
            content ?? 'سيتم فقدان التغييرات غير المحفوظة إذا رجعت الآن.',
            style: TextStyles.getSize16(
              color: AppColors.accentColor.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            // ⚠️ Go back without saving — filled primary red (destructive)
            MainButton(
              title: secondaryButtonText ?? 'رجوع بدون حفظ',
              width: 125,
              textColor: AppColors.primaryDarkColor,
              bgcolor: AppColors.secondaryColor,
              borderRadius: 14,
              hasShadow: false,
              borderColor: AppColors.secondaryColor.withValues(alpha: 0.2),
              onPressed:
                  secondaryButtonOnConfirm ??
                  () {
                    pop(context);
                    pop(context);
                  },
            ),

            const Spacer(),

            // ✅ Save and go back — filled secondary (safe, calm)
            MainButton(
              title: mainButtonText ?? 'حفظ و رجوع',
              width: 125,
              textColor: AppColors.whiteColor,
              bgcolor: AppColors.primaryColor,
              borderRadius: 14,
              hasShadow: false,
              borderColor: AppColors.primaryColor,
              onPressed:
                  mainButtonOnConfirm ??
                  () {
                    pop(context);
                  },
            ),
          ],
        ),
      ],
    ),
  );
}
