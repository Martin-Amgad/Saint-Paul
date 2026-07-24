import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/feature/splash/app_blocked_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    final String? role = FirebaseAuth.instance.currentUser?.photoURL;
    final bool isNewUser = LocalHelper.getIsNewUser() ?? true;

    // Start concurrent futures
    final updateCheckFuture =
        FirebaseProvider.checkIfUpdateAvailableOrAppUnderMaintenance();
    final appDownloadUrl = await FirebaseProvider.getAppDownloadUrl();
    // Minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    // 1. Load user‑specific data based on role (unchanged)
    if (role == '1' || role == '2') {
      // ── TEACHER ──────────────────────────────────
      TeacherModel? teacher;
      try {
        teacher = await FirebaseProvider.getTeacherByID(
          LocalHelper.getUserId(),
        );
      } catch (e) {
        log('Failed to fetch teacher: $e');
      }

      LocalHelper.setUserFamily(teacher?.assignedFamily ?? '');
      LocalHelper.setUserStudyLevel(teacher?.assignedStudyLevel ?? '');
      LocalHelper.setUserChurchName(teacher?.church ?? '');
      LocalHelper.setUserType(teacher?.role ?? '');
    } else if (role == '0') {
      // ── STUDENT ──────────────
      try {
        final doc = await FirebaseProvider.getStudentByID(
          LocalHelper.getUserId(),
        );
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          LocalHelper.setUserChurchName(data['church'] ?? '');
          LocalHelper.setUserFamily(data['family'] ?? '');
        }
      } catch (e) {
        log('Failed to fetch student: $e');
      }

      LocalHelper.setUserRole('مخدوم');
      LocalHelper.setUserType('مخدوم');
    }

    log('User role: $role.');
    log('Is new user: $isNewUser.');
    log('User family: ${LocalHelper.getUserFamily()}.');
    log('User study level: ${LocalHelper.getUserStudyLevel()}.');
    log('User type: ${LocalHelper.getUserType()}.');
    log('User church name: ${LocalHelper.getUserChurchName()}.');

    // 2. Check for updates / maintenance + version comparison
    Map<String, dynamic> updateCheck;
    try {
      updateCheck = await updateCheckFuture;
    } catch (e) {
      log('Failed to check for updates: $e');
      updateCheck = {
        'isUpdateAvailable': false,
        'isAppUnderMaintenance': false,
        'minAppVersion': null,
        'minBuildNumber': null,
      };
    }

    final isUpdateAvailable =
        updateCheck['isUpdateAvailable'] as bool? ?? false;
    final isUnderMaintenance =
        updateCheck['isAppUnderMaintenance'] as bool? ?? false;
    final minAppVersion = updateCheck['minAppVersion'] as String?;
    final minBuildNumber = updateCheck['minBuildNumber'] as int?;

    bool needsUpdateBlock = false;
    if (isUpdateAvailable) {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      log(
        'Current build number: $currentBuild, Minimum required build: $minBuildNumber',
      );
      if (minBuildNumber != null) {
        // Build number is specified → force update if current build is lower
        log(
          'Current build: $currentBuild, min required build: $minBuildNumber',
        );
        needsUpdateBlock = currentBuild < minBuildNumber;
      } else if (minAppVersion != null && minAppVersion.isNotEmpty) {
        // Fallback to version‑string comparison (for legacy configs)
        final currentVersion = packageInfo.version;
        log('Current version: $currentVersion, min required: $minAppVersion');
        needsUpdateBlock = _isVersionLower(currentVersion, minAppVersion);
      } else {
        // Neither build number nor version specified → block everyone (backward compatible)
        needsUpdateBlock = true;
      }
    }

    log('Update available: $isUpdateAvailable');
    log('App under maintenance: $isUnderMaintenance');
    log('Needs update block: $needsUpdateBlock');

    if (!mounted) return;

    // 3. Navigate
    if (needsUpdateBlock) {
      pushWithReplacement(
        context,
        Routes.appBlockedScreen,
        extra: {
          'reason': AppBlockedReason.update,
          'appDownloadUrl': appDownloadUrl,
        },
      );
    } else if (isUnderMaintenance) {
      pushWithReplacement(
        context,
        Routes.appBlockedScreen,
        extra: {
          'reason': AppBlockedReason.maintenance,
          'appDownloadUrl': appDownloadUrl,
        },
      );
    } else if (isNewUser) {
      pushWithReplacement(context, Routes.welcome);
    } else if (role == '1' || role == '2') {
      log('Navigating to main screen for teacher');
      pushWithReplacement(context, Routes.mainScreen, extra: 'خادم');
    } else {
      log('Navigating to main screen for student or other role');
      pushWithReplacement(context, Routes.mainScreen, extra: 'مخدوم');
    }
  }

  /// Returns `true` if [current] is strictly lower than [required].
  bool _isVersionLower(String current, String required) {
    final currentParts = current.split('.').map(int.parse).toList();
    final requiredParts = required.split('.').map(int.parse).toList();
    for (int i = 0; i < requiredParts.length; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (c < requiredParts[i]) return true;
      if (c > requiredParts[i]) return false;
    }
    return false; // equal or higher
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
