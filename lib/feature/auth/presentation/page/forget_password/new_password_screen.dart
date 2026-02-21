// import 'dart:developer';

// import 'package:saint_paul/components/buttons/main_button.dart';
// import 'package:saint_paul/components/inputs/custom_text_field.dart';
// import 'package:saint_paul/core/constants/app_assets.dart';
// import 'package:saint_paul/core/extentions/dialogs.dart';
// import 'package:saint_paul/core/routes/navigation.dart';
// import 'package:saint_paul/core/routes/routes.dart';
// import 'package:saint_paul/core/utils/colors.dart';
// import 'package:saint_paul/core/utils/text_styles.dart';
// import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
// import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';

// class NewPasswordScreen extends StatefulWidget {
//   const NewPasswordScreen({super.key});

//   @override
//   State<NewPasswordScreen> createState() => _NewPasswordScreenState();
// }

// class _NewPasswordScreenState extends State<NewPasswordScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<AuthCubit>();

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: false,
//         automaticallyImplyLeading: false,
//         title: GestureDetector(
//           onTap: () {
//             pop(context);
//           },
//           child: Image.asset(AppAssets.arrowBack, width: 41, height: 41),
//         ),
//       ),
//       body: SafeArea(
//         child: BlocListener<AuthCubit, AuthState>(
//           listener: _blockListener,
//           child: Padding(
//             padding: const EdgeInsets.all(22),
//             child: Form(
//               key: cubit.formkey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Create new password', style: TextStyles.getSize30()),
//                     Gap(10),
//                     Text(
//                       'Your new password must be unique from those previously used.',
//                       style: TextStyles.getSize16(color: AppColors.greyColor),
//                     ),
//                     Gap(30),
//                     CustomTextField(
//                       controller: cubit.passwordController,
//                       hintText: 'New Password',
//                       isPassword: true,
//                     ),
//                     Gap(15),
//                     CustomTextField(
//                       controller: cubit.passwordConfirmationController,
//                       hintText: 'Confirm Password',
//                       isPassword: true,
//                     ),
//                     Gap(40),
//                     MainButton(
//                       title: 'Reset password',
//                       onPressed: () {
//                         log('test1');
//                         try {
//                           if (cubit.formkey.currentState!.validate()) {
//                             print("✅ Button pressed, calling reset_password");
//                             log('test2');
//                             cubit.reset_password();
//                           }
//                         } catch (e, st) {
//                           print("🔥 Exception in onPressed: $e");
//                           print(st);
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void _blockListener(BuildContext context, AuthState state) {
//   print("📢 State changed: $state");
//   if (state is AuthloadingState) {
//     showLoadingDialog(context);
//   } else if (state is AuthSuccessState) {
//     pop(context);
//     pushTo(context, Routes.confirmScreen);
//   } else if (state is AuthErrorState) {
//     pop(context);
//     showMyDialoge(context, state.error);
//   }
// }
