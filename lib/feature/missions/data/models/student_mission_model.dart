import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class StudentMissionModel extends StatelessWidget {
  const StudentMissionModel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 10,
      separatorBuilder: (_, _) => const Gap(12),
      itemBuilder: (context, index) {
        // Cycle reward colors for visual variety
        final colors = [
          const Color(0xFFFFD700),
          AppColors.primaryColor,
          const Color(0xFF22C55E),
        ];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card top accent bar ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            'مهمة اليوم',
                            style: TextStyles.getSize18(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        // Mission number badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyles.getSize12(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.8,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    // Mission description
                    Text(
                      'اقرا من انجيل يوحنا الاصحاح 3 وعدد 16، ثم قم بعمل ملخص بسيط عنه.',
                      style: TextStyles.getSize16(
                        color: AppColors.accentColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(12),
                    // Divider
                    Divider(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      height: 1,
                    ),
                    const Gap(10),
                    // Reward row
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: const Color(0xFFFFD700),
                          size: 18,
                        ),
                        const Gap(6),
                        Text(
                          'المكافأة:',
                          style: TextStyles.getSize12(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '5 طايو',
                          style: TextStyles.getSize16(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
