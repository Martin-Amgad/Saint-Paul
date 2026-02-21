// import 'dart:developer';

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
// import 'package:gap/gap.dart';
// import 'package:pinput/pinput.dart';

// class OTPScreen extends StatefulWidget {
//   const OTPScreen({super.key});

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   bool resend = false;
//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<AuthCubit>();
//     return Scaffold(
//       bottomNavigationBar: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Didn’t received code?', style: TextStyles.getSize16()),
//             TextButton(
//               onPressed: () {
//                 resend = true;
//                 cubit.forget_password();
//               },
//               style: TextButton.styleFrom(padding: EdgeInsets.zero),
//               child: Text(
//                 'Resend',
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
//                     Text('OTP Verification', style: TextStyles.getSize30()),
//                     Text(
//                       'Enter the verification code we just sent on your email address.',
//                       style: TextStyles.getSize16(color: AppColors.greyColor),
//                     ),
//                     Gap(30),
//                     //otp window
//                     Center(child: buildPinPut(cubit)),
//                     Gap(45),
//                     MainButton(
//                       title: 'verify',
//                       onPressed: () {
//                         LocalHelper.setString(
//                           LocalHelper.Kotp,
//                           cubit.otpController.text,
//                         );
//                         log('${LocalHelper.getString(LocalHelper.Kotp)}');
//                         if (cubit.formkey.currentState!.validate()) {
//                           cubit.check_forget_password();
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

//   void _blockListener(BuildContext context, AuthState state) {
//     if (state is AuthSuccessState) {
//       pop(context);
//       if (!resend) {
//         pushTo(context, Routes.newPasswordScreen);
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("OTP resent successfully")));
//         resend = false;
//       }
//     } else if (state is AuthErrorState) {
//       pop(context);
//       showMyDialoge(context, state.error);
//     } else {
//       showLoadingDialog(context);
//     }
//   }

//   Widget buildPinPut(var cubit) {
//     final defaultPinTheme = PinTheme(
//       width: 70,
//       height: 60,
//       textStyle: TextStyles.getSize24(),
//       decoration: BoxDecoration(
//         color: AppColors.accentColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: AppColors.primaryColor, width: 2),
//       borderRadius: BorderRadius.circular(12),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         border: Border.all(color: AppColors.primaryColor, width: 2),
//         color: AppColors.whiteColor,
//       ),
//     );

//     return Pinput(
//       length: 6,
//       defaultPinTheme: defaultPinTheme,
//       focusedPinTheme: focusedPinTheme,
//       submittedPinTheme: submittedPinTheme,
//       showCursor: true,
//       controller: cubit.otpController,
//       onCompleted: (pin) {
//         print("Entered OTP: $pin");
//       },
//     );
//   }
// }
