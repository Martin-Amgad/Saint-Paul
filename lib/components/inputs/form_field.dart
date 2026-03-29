import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

/// A labelled form section with an icon and a content slot
class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.label,
    this.icon,
    required this.child,
    this.pngPicture,
  });

  final String label;
  final IconData? icon;
  final Widget child;
  final String? pngPicture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: pngPicture != null
                  ? Image.asset(
                      pngPicture!,
                      width: 16,
                      height: 16,
                      color: AppColors.primaryColor,
                    )
                  : Icon(icon, color: AppColors.primaryColor, size: 16),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyles.getSize18(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Gap(8),
        child,
      ],
    );
  }
}
