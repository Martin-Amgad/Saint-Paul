import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/page/student/student_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/birthday_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/teacher_home_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/student/student_mission_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/teacher/teacher_mission_screen.dart';
import 'package:saint_paul/feature/profile/presentation/student/student_profile_screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/edit_student_info_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key, this.role});
  final String? role;

  @override
  State<MainAppScreen> createState() => _MainPageState();
}

class _MainPageState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  List<Widget> get pages => widget.role == 'خادم'
      ? [
          const TeacherHomeScreen(),
          const BirthdayScreen(),
          const TeacherMissionScreen(),
          const StudentProfileEditScreen(),
        ]
      : [
          const StudentHomeScreen(),
          StudentMissionScreen(),
          const StudentProfileScreen(),
        ];

  List<GButton> get tabs => widget.role == 'خادم'
      ? [
          GButton(iconSize: 28, icon: Icons.local_atm, text: 'طايو'),
          GButton(icon: Icons.cake, text: 'أعياد الميلاد'),
          GButton(iconSize: 29, icon: Icons.assignment, text: 'المهام'),
          GButton(iconSize: 29, icon: Icons.people, text: 'المخدومون'),
        ]
      : [
          GButton(iconSize: 28, icon: Icons.leaderboard, text: 'المتصدرين'),
          GButton(icon: Icons.assignment, text: 'المهام'),
          GButton(iconSize: 29, icon: Icons.person, text: 'الحساب'),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.primaryColor.withValues(alpha: 0.2),
            ),
          ],
        ),
        child: GNav(
          curve: Curves.easeOutExpo,
          rippleColor: AppColors.primaryColor.withValues(alpha: 0.1),
          hoverColor: AppColors.primaryColor.withValues(alpha: 0.1),
          backgroundColor: Colors.transparent,
          haptic: true,
          tabBorderRadius: 15,
          gap: 5,
          activeColor: AppColors.whiteColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: AppColors.primaryColor,
          textStyle: TextStyles.getSize18(color: AppColors.whiteColor),
          tabs: tabs, // ← use getter
          selectedIndex: _selectedIndex,
          onTabChange: (value) {
            setState(() => _selectedIndex = value);
          },
        ),
      ),
    );
  }
}
