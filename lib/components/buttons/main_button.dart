import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 55,
    this.fontSize = 16,
    this.bgcolor = AppColors.primaryColor,
    this.textColor = AppColors.whiteColor,
    this.borderColor,
    this.borderRadius = 14,
    this.hasShadow = true,
  });

  final String title;
  final Function() onPressed;
  final double width;
  final double height;
  final double fontSize;
  final Color bgcolor;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: bgcolor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: bgcolor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: borderColor ?? Colors.transparent,
                width: borderColor != null ? 1.5 : 0,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyles.getSize16(color: textColor, fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}
