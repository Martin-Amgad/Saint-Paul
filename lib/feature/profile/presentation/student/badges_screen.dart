import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

// Full badge model — all possible badges
final Map<String, String> badgeModel = {
  'ملك التايـو': AppAssets.tayoKing,
  'بطل الانتظام': AppAssets.consistencyChampion,
  'فارس المهمات': AppAssets.missionMaster,
  'البطل الصامت': AppAssets.silentKing,
  'نجم المعرفة': AppAssets.smartstar,
};

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.earnedBadgeKeys});

  // Only the keys the student has earned
  final List<String> earnedBadgeKeys;

  @override
  Widget build(BuildContext context) {
    final earnedBadges = badgeModel.entries
        .where((e) => earnedBadgeKeys.contains(e.key))
        .toList();
    final lockedBadges = badgeModel.entries
        .where((e) => !earnedBadgeKeys.contains(e.key))
        .toList();

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
                // Back button
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
                        Icons.military_tech_rounded,
                        color: AppColors.yellowIconColor,
                        size: 26,
                      ),
                    ),
                    const Gap(14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أوسمتي',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'اكتشف إنجازاتك',
                          style: TextStyles.getSize12(
                            color: AppColors.whiteColor.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(16),
                // Progress pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.yellowIconColor,
                        size: 18,
                      ),
                      const Gap(8),
                      Text(
                        '${earnedBadges.length} من ${badgeModel.length} أوسمة',
                        style: TextStyles.getSize16(
                          color: AppColors.whiteColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(10),
                      // Progress bar
                      Container(
                        width: 80,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: earnedBadges.length / badgeModel.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.yellowIconColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Badge grid ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Earned badges
                  if (earnedBadges.isNotEmpty) ...[
                    _SectionLabel(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.yellowIconColor,
                      label: 'أوسمة محققة',
                    ),
                    const Gap(12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: earnedBadges.length,
                      itemBuilder: (context, index) {
                        return _BadgeCard(
                          name: earnedBadges[index].key,
                          assetPath: earnedBadges[index].value,
                          isEarned: true,
                        );
                      },
                    ),
                    const Gap(24),
                  ],

                  // Locked badges
                  if (lockedBadges.isNotEmpty) ...[
                    _SectionLabel(
                      icon: Icons.lock_rounded,
                      color: AppColors.accentColor.withValues(alpha: 0.4),
                      label: 'أوسمة مقفلة',
                    ),
                    const Gap(12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: lockedBadges.length,
                      itemBuilder: (context, index) {
                        return _BadgeCard(
                          name: lockedBadges[index].key,
                          assetPath: lockedBadges[index].value,
                          isEarned: false,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyles.getSize16(
            color: AppColors.accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.name,
    required this.assetPath,
    required this.isEarned,
  });

  final String name;
  final String assetPath;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.yellowIconColor.withValues(alpha: 0.07)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned
              ? AppColors.yellowIconColor.withValues(alpha: 0.35)
              : AppColors.borderColor.withValues(alpha: 0.5),
          width: isEarned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned
                ? AppColors.yellowIconColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isEarned ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge image
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned
                      ? AppColors.yellowIconColor.withValues(alpha: 0.12)
                      : AppColors.accentColor.withValues(alpha: 0.05),
                ),
              ),
              ColorFiltered(
                colorFilter: isEarned
                    ? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      )
                    : const ColorFilter.matrix([
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                child: Image.asset(
                  assetPath,
                  width: 60,
                  height: 60,
                  opacity: AlwaysStoppedAnimation(isEarned ? 1.0 : 0.3),
                ),
              ),
              if (!isEarned)
                Icon(
                  Icons.lock_rounded,
                  color: AppColors.accentColor.withValues(alpha: 0.3),
                  size: 22,
                ),
            ],
          ),
          const Gap(10),
          // Badge name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyles.getSize16(
                color: isEarned
                    ? AppColors.accentColor
                    : AppColors.accentColor.withValues(alpha: 0.35),
                fontWeight: isEarned ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(6),
          // Earned indicator
          if (isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.yellowIconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'محقق ✓',
                style: TextStyles.getSize12(
                  color: AppColors.yellowIconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
