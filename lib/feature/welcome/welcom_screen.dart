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

            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'سجل دلوقتى گ',
                    style: TextStyles.getSize18(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(20),
                  MainButton(
                    title: 'خادم',
                    bgcolor: AppColors.secondaryColor.withValues(alpha: 1.1),
                    textColor: AppColors.primaryColor,
                    borderColor: AppColors.primaryColor.withValues(alpha: 0.5),
                    onPressed: () {
                      LocalHelper.setUserType('خادم');
                      pushTo(context, Routes.register, extra: 'خادم');
                    },
                  ),
                  Gap(15),
                  MainButton(
                    title: 'مخدوم',
                    bgcolor: AppColors.secondaryColor.withValues(alpha: 1.1),
                    textColor: AppColors.primaryColor,
                    borderColor: AppColors.primaryColor.withValues(alpha: 0.5),
                    onPressed: () {
                      LocalHelper.setUserType('مخدوم');
                      pushTo(context, Routes.register, extra: 'مخدوم');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
