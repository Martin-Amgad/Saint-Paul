import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:flutter/material.dart';
import 'package:saint_paul/core/utils/colors.dart';

class AppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithBack({super.key, this.action});
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [action ?? const SizedBox()],
      title: GestureDetector(
        onTap: () {
          pop(context);
        },
        child: Image.asset(
          AppAssets.arrowBack,
          width: 41,
          height: 41,
          color: AppColors.accentColor,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
