import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class WelcomScreen extends StatelessWidget {
  const WelcomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppAssets.welcome,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 50,
            bottom: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Hero(
                  tag: 'splash_logo',
                  child: Image.asset(AppAssets.logo, width: 300, height: 300),
                ),
                Gap(15),
                Spacer(flex: 3),
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 50,

            child: Column(
              children: [
                MainButton(
                  title: 'تسجيل دخول',
                  bgcolor: AppColors.primaryColor,
                  textColor: AppColors.whiteColor,
                  borderColor: AppColors.secondaryColor.withValues(alpha: 0.5),
                  onPressed: () {
                    pushTo(context, Routes.login);
                  },
                ),
                Gap(15),
                MainButton(
                  title: 'انشاء حساب جديد',
                  bgcolor: AppColors.primaryColor,
                  textColor: AppColors.whiteColor,

                  borderColor: AppColors.secondaryColor.withValues(alpha: 0.5),
                  onPressed: () {
                    pushTo(context, Routes.register);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
