// import 'package:saint_paul/components/buttons/main_button.dart';
// import 'package:saint_paul/components/inputs/custom_text_field.dart';
// import 'package:saint_paul/core/constants/app_assets.dart';
// import 'package:saint_paul/core/extentions/dialogs.dart';
// import 'package:saint_paul/core/routes/navigation.dart';
// import 'package:saint_paul/core/routes/routes.dart';
// import 'package:saint_paul/core/services/local/local_helper.dart';
// import 'package:saint_paul/core/utils/colors.dart';
// import 'package:saint_paul/core/utils/text_styles.dart';
// import 'package:saint_paul/feature/auth/presentation/cubit/auth_cubit.dart';
// import 'package:saint_paul/feature/auth/presentation/cubit/auth_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';

// class EmailScreen extends StatefulWidget {
//   const EmailScreen({super.key});

//   @override
//   State<EmailScreen> createState() => _EmailScreenState();
// }

// class _EmailScreenState extends State<EmailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<AuthCubit>();
//     return Scaffold(
//       bottomNavigationBar: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Remember Password?', style: TextStyles.getSize16()),
//             TextButton(
//               onPressed: () {
//                 pop(context);
//               },
//               style: TextButton.styleFrom(padding: EdgeInsets.zero),
//               child: Text(
//                 'Login',
//                 style: TextStyles.getSize16(color: AppColors.primaryColor),
//               ),
//             ),
//           ],
//         ),
//       ),
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
//                     Text('Forgot Password?', style: TextStyles.getSize30()),
//                     Text(
//                       'Don\'t worry! It occurs. Please enter the email address linked with your account.',
//                       style: TextStyles.getSize16(color: AppColors.greyColor),
//                     ),
//                     Gap(30),
//                     CustomTextField(
//                       controller: cubit.emailController,
//                       hintText: 'Enter Your Email',
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'please enter Email';
//                         }
//                       },
//                     ),
//                     Gap(15),

//                     Gap(30),
//                     MainButton(
//                       title: 'Send Code',
//                       onPressed: () {
//                         LocalHelper.setString(
//                           LocalHelper.KEmail,
//                           cubit.emailController.text,
//                         );
//                         if (cubit.formkey.currentState!.validate()) {
//                           cubit.forget_password();
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
//   if (state is AuthSuccessState) {
//     pop(context);
//     pushTo(context, Routes.otpScreen);
//   } else if (state is AuthErrorState) {
//     pop(context);
//     showMyDialoge(context, state.error);
//   } else {
//     showLoadingDialog(context);
//   }
// }
