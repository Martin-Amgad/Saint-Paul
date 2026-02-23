import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/page/student/student_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/birthday_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/teacher_home_screen.dart';
import 'package:saint_paul/feature/home/profile/presentation/teacher/teacher_profile_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key, this.role});
  final String? role;

  @override
  State<MainAppScreen> createState() => _MainPageState();
}

class _MainPageState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  List<Widget> get pages => [
    if (widget.role == 'خادم')
      const TeacherHomeScreen()
    else
      const StudentHomeScreen(),
    if (widget.role == 'خادم')
      const BirthdayScreen()
    else
      const Center(child: Text('المهام')),
    if (widget.role == 'خادم')
      const TeacherProfileScreen()
    else
      const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
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
            tabBorderRadius: 20,
            gap: 5,
            activeColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: AppColors.primaryColor,
            textStyle: TextStyles.getSize18(color: AppColors.whiteColor),
            tabs: [
              widget.role == 'خادم'
                  ? GButton(iconSize: 28, icon: Icons.home, text: 'الرئيسية')
                  : GButton(
                      iconSize: 28,
                      icon: Icons.leaderboard,
                      text: 'المتصدرين',
                    ),
              widget.role == 'خادم'
                  ? GButton(icon: Icons.cake, text: 'اعياد الميلاد')
                  : GButton(icon: Icons.assignment, text: 'المهام'),
              //  widget.role == "teacher"
              //     ? GButton(
              //         iconSize: 28,
              //         icon: Icons.calendar_month_rounded,
              //         text: 'المواعيد',
              //       )
              //     : GButton(
              //         iconSize: 28,
              //         icon: Icons.calendar_month_rounded,
              //         text: 'المواعيد',
              //       ),
              widget.role == 'خادم'
                  ? GButton(iconSize: 29, icon: Icons.person, text: 'الحساب')
                  : GButton(iconSize: 29, icon: Icons.person, text: 'الحساب'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
