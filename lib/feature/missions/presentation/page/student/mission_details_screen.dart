import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class MissionDetailsScreen extends StatelessWidget {
  const MissionDetailsScreen({super.key, required this.mission});
  final MissionModel mission;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              28,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBackButton(),
                const Gap(18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.assignment_rounded,
                        color: AppColors.whiteColor,
                        size: 24,
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Text(
                        mission.title ?? 'مهمة',
                        style: TextStyles.getSize24(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                // Reward pill in header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellowIconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.yellowIconColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.yellowIconColor,
                        size: 18,
                      ),
                      const Gap(6),
                      Text(
                        'المكافأة: ${mission.reward ?? '0'} طايو',
                        style: TextStyles.getSize16(
                          color: AppColors.yellowIconColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description card
                  _SectionCard(
                    icon: Icons.description_rounded,
                    iconColor: AppColors.primaryColor,
                    label: 'محتوى المهمة',
                    child: Text(
                      mission.description ?? 'لا يوجد وصف',
                      style: TextStyles.getSize16(
                        color: AppColors.accentColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const Gap(14),

                  // Link card — only if link exists
                  if ((mission.link ?? '').isNotEmpty)
                    _SectionCard(
                      icon: Icons.link_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      label: 'الرابط',
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(mission.link!));
                              },
                              child: Text(
                                mission.link!,
                                style: TextStyles.getSize16(
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.open_in_new_rounded,
                              color: Color(0xFF3B82F6),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.08),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyles.getSize16(
                  color: AppColors.accentColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(10),
          child,
        ],
      ),
    );
  }
}
