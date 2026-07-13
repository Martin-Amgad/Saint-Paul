import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:super_tooltip/super_tooltip.dart';

/// A labelled form section with an icon and a content slot
class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.label,
    this.icon,
    required this.child,
    this.pngPicture,
    this.infoHoverText,
  });

  final String label;
  final IconData? icon;
  final Widget child;
  final String? pngPicture;
  final String? infoHoverText;

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
            Row(
              children: [
                Text(
                  label,
                  style: TextStyles.getSize18(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (infoHoverText != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: SuperTooltip(
                      arrowConfig: const ArrowConfiguration(
                        length: 15,
                        baseWidth: 10,
                      ),
                      content: Text(
                        infoHoverText!,
                        style: TextStyles.getSize24(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                      child: const Icon(Icons.info_outline),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const Gap(8),
        child,
      ],
    );
  }
}
