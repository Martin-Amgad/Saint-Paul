import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/splash/app_blocked_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  bool? updateAvailable = false;
  bool? underMaintenance = false;

  Future<void> checkIfThereIsAnUpdate() async {
    bool isUpdateAvailable = await FirebaseProvider.checkIfUpdateAvailable();
    bool isUnderMaintenance =
        await FirebaseProvider.checkIfAppUnderMaintenance();
    setState(() {
      updateAvailable = isUpdateAvailable;
      underMaintenance = isUnderMaintenance;
    });
    log('Checked for updates: $updateAvailable');
    log('App under maintenance: $underMaintenance');
  }

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    // _getAndStoreStudentData();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final String? userType = FirebaseAuth.instance.currentUser?.photoURL;
    final bool isNewUser = LocalHelper.getIsNewUser() ?? true;

    // Wait for BOTH the minimum splash duration AND the update check
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      FirebaseProvider.checkIfUpdateAvailable(),
      FirebaseProvider.checkIfAppUnderMaintenance(),
    ]);

    final bool isUpdateAvailable = results[1] as bool;
    final bool isUnderMaintenance = results[2] as bool;
    log('Update available: $isUpdateAvailable');
    log('App under maintenance: $isUnderMaintenance');
    if (!mounted) return;

    if (isUpdateAvailable) {
      pushWithReplacement(
        context,
        Routes.appBlockedScreen,
        extra: AppBlockedReason.update,
      );
    } else if (isUnderMaintenance == true) {
      pushWithReplacement(
        context,
        Routes.appBlockedScreen,
        extra: AppBlockedReason.maintenance,
      );
    } else if (isNewUser) {
      pushWithReplacement(context, Routes.welcome);
    } else if (userType == '1') {
      pushWithReplacement(context, Routes.mainScreen, extra: 'خادم');
    } else {
      pushWithReplacement(context, Routes.mainScreen, extra: 'مخدوم');
    }
  }

  // Future<void> _getAndStoreStudentData() async {
  //   var snapshot = await FirebaseProvider.getStudentByID(
  //     LocalHelper.getUserId(),
  //   );

  /// for now commented in debugging,
  /// but will be used later to store user data locally
  ///
  ///
  // var userData = StudentModel.fromJson(
  //   snapshot.data() as Map<String, dynamic>,
  //   snapshot.id,
  // );
  // LocalHelper.setUserData(userData.toJsonLocal());
  // LocalHelper.setUserGroup('${userData.groupID}');
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ───────────────────────────────────────
          Image.asset(
            AppAssets.welcome,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // ── Dark overlay for depth ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          // ── Animated content ───────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with fade + scale
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Hero(
                      tag: 'splash_logo',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          width: 180,
                          height: 180,
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
