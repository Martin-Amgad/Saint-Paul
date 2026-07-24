import 'package:flutter/material.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onTap, this.icon});
  final Function()? onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            pop(context);
          },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon ?? Icons.arrow_back_ios_rounded,
          color: AppColors.whiteColor,
          size: 22,
        ),
      ),
    );
  }
}
