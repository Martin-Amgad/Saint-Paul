import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/routes/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    String? userType = FirebaseAuth.instance.currentUser?.photoURL;
    bool? isNewUser = LocalHelper.getIsNewUser() ?? true;
    log('User type from Firebase: $userType');

    Future.delayed(Duration(seconds: 2), () {
      log('Checking if user is new: ${LocalHelper.getIsNewUser()}');
      if (isNewUser == true) {
        pushWithReplacement(context, Routes.welcome);
      } else if (userType == '1') {
        pushWithReplacement(context, Routes.mainScreen, extra: 'خادم');
      } else {
        pushWithReplacement(context, Routes.mainScreen, extra: 'مخدوم');
      }
    });
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'splash_logo',
                  child: Image.asset(AppAssets.logo, width: 200, height: 200),
                ),
                Gap(15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
