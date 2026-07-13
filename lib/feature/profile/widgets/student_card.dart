import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final bool isSelected; // highlight when selected (edit screen)
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const StudentCard({
    super.key,
    required this.student,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkYellowIconColor.withValues(alpha: 0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.darkYellowIconColor.withValues(alpha: 0.5)
                : AppColors.primaryColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
              child: ClipOval(
                child:
                    student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: student.avatarUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
                        size: 30,
                      ),
              ),
            ),
            const Gap(4),
            Text(
              student.name ?? 'بدون اسم',
              style: TextStyles.getSize18(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if ((student.studyLevel ?? '').isNotEmpty) ...[
              const Gap(2),
              Text(
                student.studyLevel!,
                style: TextStyles.getSize12(
                  color: AppColors.accentColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
