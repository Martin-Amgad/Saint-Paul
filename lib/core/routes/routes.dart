import 'package:flutter/material.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:saint_paul/feature/auth/presentation/page/forget_password/password_changed_screen.dart';
import 'package:saint_paul/feature/auth/presentation/page/login/login_screen.dart';
import 'package:saint_paul/feature/auth/presentation/page/register/register_screen%20.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/page/student/student_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/add_new_student_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/teacher_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/tayo_details_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/student/student_mission_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/teacher/create_mission_screen.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/student/student_profile_screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/edit_student_info_screen.dart';
import 'package:saint_paul/feature/main/nav_bar.dart';
import 'package:saint_paul/feature/splash/splash_screen.dart';
import 'package:saint_paul/feature/welcome/welcom_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/Register';
  static const String emailScreen = '/emailScreen';
  static const String otpScreen = '/otpScreen';
  static const String newPasswordScreen = '/NewPasswordScreen';
  static const String confirmScreen = '/confirmScreen';
  static const String mainScreen = '/mainScreen';
  static const String teacherHomeScreen = '/teacherHomeScreen';
  static const String addEditNewStudentScreen = '/addNewStudentScreen';
  static const String studentHomeScreen = '/studentHomeScreen';
  static const String tayoDetailsScreen = '/tayoDetailsScreen';
  static const String studentInfoEditScreen = '/studentInfoEditScreen';
  static const String studentProfileScreen = '/studentProfileScreen';
  static const String studentMissionScreen = '/studentMissionScreen';
  static const String createMissionScreen = '/createMissionScreen';

  static final routes = GoRouter(
    routes: [
      GoRoute(path: splash, builder: (context, state) => SplashScreen()),
      GoRoute(path: welcome, builder: (context, state) => WelcomScreen()),
      GoRoute(
        path: login,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: RegisterScreen(),
        ),
      ),

      GoRoute(
        path: mainScreen,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => HomeCubit()),
            BlocProvider(create: (context) => ProfileCubit()),
          ],
          child: MainAppScreen(role: state.extra as String?),
        ),
      ),

      GoRoute(
        path: addEditNewStudentScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => HomeCubit(),
          child: AddEditNewStudentScreen(student: state.extra as StudentModel?),
        ),
      ),

      GoRoute(
        path: studentInfoEditScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: StudentProfileEditScreen(),
        ),
      ),

      GoRoute(
        path: studentProfileScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: StudentProfileScreen(),
        ),
      ),

      GoRoute(
        path: studentMissionScreen,
        builder: (context, state) => StudentMissionScreen(),
      ),

      GoRoute(
        path: createMissionScreen,
        builder: (context, state) => CreateMissionScreen(),
      ),

      // GoRoute(
      //   path: emailScreen,
      //   builder: (context, state) => BlocProvider(
      //     create: (context) => AuthCubit(),
      //     child: EmailScreen(),
      //   ),
      // ),
      // GoRoute(
      //   path: otpScreen,
      //   builder: (context, state) =>
      //       BlocProvider(create: (context) => AuthCubit(), child: OTPScreen()),
      // ),
      // GoRoute(
      //   path: newPasswordScreen,
      //   builder: (context, state) => BlocProvider(
      //     create: (context) => AuthCubit(),
      //     child: NewPasswordScreen(),
      //   ),
      // ),
      GoRoute(
        path: confirmScreen,
        builder: (context, state) => PasswordChangedScreen(),
      ),

      GoRoute(
        path: teacherHomeScreen,
        builder: (context, state) => TeacherHomeScreen(),
      ),

      GoRoute(
        path: studentHomeScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => HomeCubit(),
          child: Builder(
            // ← add Builder here
            builder: (context) => StudentHomeScreen(),
          ),
        ),
      ),

      GoRoute(
        path: tayoDetailsScreen,

        builder: (context, state) => BlocProvider(
          create: (context) => HomeCubit(),
          child: TayoDetailsScreen(student: state.extra as StudentModel),
        ),
      ),
    ],
  );
}
