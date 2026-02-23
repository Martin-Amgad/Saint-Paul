import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saint_paul/core/utils/colors.dart';

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    this.icon,
    this.svgAsset,
    required this.onTap,
  });

  final IconData? icon;
  final String? svgAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.whiteColor,
                  BlendMode.srcIn,
                ),
              )
            : Icon(icon, color: AppColors.whiteColor, size: 20),
      ),
    );
  }
}
