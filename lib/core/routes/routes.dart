import 'package:flutter/material.dart';
import 'package:saint_paul/core/models/group_model.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/models/teacher_model.dart';
import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:saint_paul/feature/auth/presentation/page/login/login_screen.dart';
import 'package:saint_paul/feature/auth/presentation/page/register/register_new_church_screen.dart';
import 'package:saint_paul/feature/auth/presentation/page/register/register_screen%20.dart';
import 'package:saint_paul/feature/groups/presentation/cubit/group_cubit.dart';
import 'package:saint_paul/feature/groups/presentation/page/student/group_details_screen.dart';
import 'package:saint_paul/feature/groups/presentation/page/teacher/create_group_screen.dart';
import 'package:saint_paul/feature/groups/presentation/page/teacher/group_points_screen.dart';
import 'package:saint_paul/feature/groups/presentation/page/teacher/groups_showcase_screen.dart';
import 'package:saint_paul/feature/history/presentation/cubit/history_cubit.dart';
import 'package:saint_paul/feature/history/presentation/page/tayo_history_screen.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/page/student/student_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/add_edit_new_student_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/students_excel_upload_screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/miss_check_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/teacher_home_screen.dart';
import 'package:saint_paul/feature/home/presentation/page/teacher/tayo_details_screen.dart';
import 'package:saint_paul/feature/missions/widgets/student_missions_list.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/page/student/mission_details_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/student/student_mission_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/teacher/create_and_edit_mission_screen.dart';
import 'package:saint_paul/feature/missions/presentation/page/teacher/teacher_mission_screen.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/student/badges_screen.dart';
import 'package:saint_paul/feature/profile/presentation/student/student_profile_screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/edit_teacher_students_screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/edit_teachers_info_Screen.dart';
import 'package:saint_paul/feature/profile/presentation/teacher/students_showcase_and_edit_screen.dart';
import 'package:saint_paul/feature/main/nav_bar.dart';
import 'package:saint_paul/feature/splash/splash_screen.dart';
import 'package:saint_paul/feature/splash/app_blocked_screen.dart';
import 'package:saint_paul/feature/welcome/welcom_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/Register';
  static const String registerNewChurch = '/RegisterNewChurch';
  static const String emailScreen = '/emailScreen';
  static const String otpScreen = '/otpScreen';
  static const String newPasswordScreen = '/NewPasswordScreen';
  static const String confirmScreen = '/confirmScreen';
  static const String mainScreen = '/mainScreen';
  static const String teacherHomeScreen = '/teacherHomeScreen';
  static const String addEditNewStudentScreen = '/addNewStudentScreen';
  static const String studentHomeScreen = '/studentHomeScreen';
  static const String tayoDetailsScreen = '/tayoDetailsScreen';
  static const String studentShowcaseAndEditScreen =
      '/studentShowcaseAndEditScreen';
  static const String studentProfileScreen = '/studentProfileScreen';
  static const String studentMissionScreen = '/studentMissionScreen';
  static const String teacherMissionScreen = '/teacherMissionScreen';
  static const String createMissionScreen = '/createMissionScreen';
  static const String missionDetailsScreen = '/missionDetailsScreen';
  static const String studentMissionsList = '/studentMissionsList';
  static const String badgesScreen = '/badgesScreen';
  static const String groupShowcaseScreen = '/groupShowcaseScreen';
  static const String createGroupScreen = '/createGroupScreen';
  static const String groupDetailsScreen = '/groupDetailsScreen';
  static const String appBlockedScreen = '/appBlockedScreen';
  static const String groupPointsScreen = '/groupPointsScreen';
  static const String tayoHistoryScreen = '/tayoHistoryScreen';
  static const String editTeachersInfoScreen = '/editTeachersInfoScreen';
  static const String editTeacherStudents = '/editTeacherStudents';
  static const String missCheckStudentScreen = '/missCheckStudentScreen';
  static const String studentsExcelUploadScreen = '/StudentsExcelUploadScreen';

  static final routes = GoRouter(
    routes: [
      //Main Screen /////////////////////////////////////////////
      GoRoute(
        path: mainScreen,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => HomeCubit()),
            BlocProvider(create: (context) => ProfileCubit()),
            BlocProvider(create: (context) => MissionCubit()),
            BlocProvider(create: (context) => GroupCubit()),
          ],
          child: MainAppScreen(role: state.extra as String?),
        ),
      ),
      //Auth Cubit Screens ////////////////////////////////////////
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
        path: registerNewChurch,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: RegisterNewChurchScreen(),
        ),
      ),

      //Profile Cubit Screens ////////////////////////////////////////
      GoRoute(
        path: studentShowcaseAndEditScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: StudentsShowcaseAndEditScreen(),
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
        path: badgesScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: BadgesScreen(earnedBadges: state.extra as Map<String, String>),
        ),
      ),

      GoRoute(
        path: tayoHistoryScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => HistoryCubit(),
          child: TayoHistoryScreen(groupId: state.extra as String?),
        ),
      ),

      GoRoute(
        path: editTeachersInfoScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: EditTeachersInfoScreen(teacher: state.extra as TeacherModel?),
        ),
      ),
      GoRoute(
        path: editTeacherStudents,
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: EditTeacherStudentsScreen(
            teacher: state.extra as TeacherModel,
          ),
        ),
      ),

      GoRoute(
        path: missCheckStudentScreen,
        builder: (context, state) => StudentsMissCheckScreen(),
      ),

      //Mission Cubit Screens ////////////////////////////////////////
      GoRoute(
        path: studentMissionScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => MissionCubit(),
          child: StudentMissionScreen(),
        ),
      ),

      GoRoute(
        path: createMissionScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => MissionCubit(),
          child: CreateAndEditMissionScreen(
            missionEdit: state.extra as MissionModel?,
          ),
        ),
      ),

      GoRoute(
        path: teacherMissionScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => MissionCubit(),
          child: TeacherMissionScreen(),
        ),
      ),

      GoRoute(
        path: missionDetailsScreen,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;

          final mission = args['mission'] as MissionModel;
          final isAvailable = args['isAvailable'] as bool?;
          return BlocProvider(
            create: (context) => MissionCubit(),
            child: MissionDetailsScreen(
              mission: mission,
              isAvailable: isAvailable,
            ),
          );
        },
      ),

      GoRoute(
        path: studentMissionsList,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final missions = args['missions'] as List<MissionModel>;
          final isAvailable = args['isAvailable'] as bool;

          return BlocProvider(
            create: (context) => MissionCubit(),
            child: StudentMissionsList(
              missions: missions,
              isStudent: false,
              isAvailable: isAvailable,
            ),
          );
        },
      ),

      //Group Cubit Screens ////////////////////////////////////////
      GoRoute(
        path: groupShowcaseScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => GroupCubit(),
            child: GroupsShowcaseScreen(),
          );
        },
      ),

      GoRoute(
        path: createGroupScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => GroupCubit(),
            child: CreateGroupScreen(),
          );
        },
      ),

      GoRoute(
        path: groupDetailsScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => GroupCubit(),
            child: GroupDetailsScreen(group: state.extra as GroupModel?),
          );
        },
      ),

      GoRoute(
        path: groupPointsScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => GroupCubit(),
            child: GroupPointsScreen(group: state.extra as GroupModel?),
          );
        },
      ),
      //Home Cubit Screens ////////////////////////////////////////
      GoRoute(
        path: addEditNewStudentScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => HomeCubit(),
          child: AddEditNewStudentScreen(student: state.extra as StudentModel?),
        ),
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

      //No Cubit Screens ////////////////////////////////////////
      GoRoute(path: splash, builder: (context, state) => SplashScreen()),

      GoRoute(
        path: welcome,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: WelcomScreen(),
        ),
      ),

      GoRoute(
        path: appBlockedScreen,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final reason = args['reason'] as AppBlockedReason;
          final appDownloadUrl = args['appDownloadUrl'] as String?;
          return AppBlockedScreen(
            reason: reason,
            appDownloadUrl: appDownloadUrl ?? '',
          );
        },
      ),

      GoRoute(
        path: teacherHomeScreen,
        builder: (context, state) => TeacherHomeScreen(),
      ),

      GoRoute(
        path: studentsExcelUploadScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => HomeCubit(),
          child: StudentsExcelUploadScreen(),
        ),
      ),
    ],
  );
}
