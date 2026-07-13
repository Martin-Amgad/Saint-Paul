import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/badge_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_state.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key, required this.earnedBadges});

  final Map<String, String> earnedBadges;

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    final church = LocalHelper.getUserChurchName() ?? '';
    final family = LocalHelper.getUserFamily() ?? '';
    context.read<ProfileCubit>().loadBadges(church, family);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Use badges from state only when loaded; otherwise empty list for header display
        final allBadges = state is ProfileBadgesLoadedState
            ? state.badges
            : <BadgeModel>[];
        final earnedCount = widget.earnedBadges.length;
        final total = allBadges.length;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              // ── Header (always visible) ──────────────────────────
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
                            color: AppColors.darkYellowIconColor,
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
                                color: AppColors.whiteColor.withValues(
                                  alpha: 0.65,
                                ),
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
                            color: AppColors.darkYellowIconColor,
                            size: 18,
                          ),
                          const Gap(8),
                          Text(
                            '$earnedCount من $total أوسمة',
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(10),
                          // Progress bar
                          Container(
                            width: 80,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerRight,
                              widthFactor: total > 0
                                  ? (earnedCount / total)
                                  : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkYellowIconColor,
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

              // ── Content (changes with state) ─────────────────────
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // Helper that renders the appropriate body below the header
  // ------------------------------------------------------
  Widget _buildContent(BuildContext context, ProfileState state) {
    // Loading state
    if (state is ProfileLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state is ProfileErrorState) {
      return Center(child: Text('Error: ${state.message}'));
    }

    // Loaded state – show the badge grids
    if (state is ProfileBadgesLoadedState) {
      final allBadges = state.badges;
      final allBadgesById = <String, BadgeModel>{
        for (final badge in allBadges)
          if (badge.bId != null && badge.bId!.isNotEmpty) badge.bId!: badge,
      };

      final earnedBadgeIds = widget.earnedBadges.keys.toSet();
      final lockedBadges = allBadges
          .where(
            (b) => (b.bId == null || b.bId!.isEmpty)
                ? !widget.earnedBadges.containsKey(b.name)
                : !earnedBadgeIds.contains(b.bId),
          )
          .toList();

      final earnedBadgesForUi = widget.earnedBadges.entries.map((entry) {
        final badgeIdOrName = entry.key;
        final fromId = allBadgesById[badgeIdOrName];
        final displayName = fromId?.name ?? badgeIdOrName;
        final displayUrl = (fromId?.url?.isNotEmpty ?? false)
            ? fromId!.url!
            : entry.value;
        return MapEntry(displayName, displayUrl);
      }).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earned badges
            if (earnedBadgesForUi.isNotEmpty) ...[
              _SectionLabel(
                icon: Icons.check_circle_rounded,
                color: AppColors.darkYellowIconColor,
                label: 'أوسمة محققة',
              ),
              const Gap(12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: earnedBadgesForUi.length,
                itemBuilder: (context, index) {
                  final earnedBadge = earnedBadgesForUi[index];
                  return _BadgeCard(
                    name: earnedBadge.key,
                    assetPath: earnedBadge.value,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: lockedBadges.length,
                itemBuilder: (context, index) {
                  return _BadgeCard(
                    name: lockedBadges[index].name ?? 'وسام مقفل',
                    assetPath: lockedBadges[index].url ?? '',
                    isEarned: false,
                  );
                },
              ),
            ],
          ],
        ),
      );
    }

    // Fallback (should never happen)
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────
//  _SectionLabel & _BadgeCard remain exactly as before
// ─────────────────────────────────────────────────────────────

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
            ? AppColors.darkYellowIconColor.withValues(alpha: 0.07)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned
              ? AppColors.darkYellowIconColor.withValues(alpha: 0.35)
              : AppColors.borderColor.withValues(alpha: 0.5),
          width: isEarned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned
                ? AppColors.darkYellowIconColor.withValues(alpha: 0.1)
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
                      ? AppColors.darkYellowIconColor.withValues(alpha: 0.12)
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
                child: CachedNetworkImage(
                  imageUrl: assetPath,
                  width: 48,
                  height: 48,
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
                color: AppColors.darkYellowIconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'محقق ✓',
                style: TextStyles.getSize12(
                  color: AppColors.darkYellowIconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
