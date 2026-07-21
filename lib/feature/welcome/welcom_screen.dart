import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';

class WelcomScreen extends StatefulWidget {
  const WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getChurches();
  }

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
            bottom: 30,

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
                Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "هل تمثل كنيسة جديدة؟ ",
                      style: TextStyles.getSize16(),
                    ),
                    TextButton(
                      onPressed: () {
                        pushTo(context, Routes.registerNewChurch);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'سجلها الآن',
                        style: TextStyles.getSize16(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
