import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/history/presentation/cubit/history_cubit.dart';
import 'package:saint_paul/feature/history/presentation/cubit/history_state.dart';

/// UI-only model for a single history entry.

class TayoHistoryScreen extends StatefulWidget {
  const TayoHistoryScreen({super.key, this.groupId});
  final String? groupId;

  @override
  State<TayoHistoryScreen> createState() => _TayoHistoryScreenState();
}

class _TayoHistoryScreenState extends State<TayoHistoryScreen> {
  List<TayoHistoryModel> historyList = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    var cubit = context.read<HistoryCubit>();
    if (widget.groupId != null) {
      cubit.loadPointsHistory(widget.groupId!);
    } else {
      cubit.loadTayoHistory(LocalHelper.getUserId() ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoadingState) {
            isLoading = true;
          } else if (state is HistoryErrorState) {
            isLoading = false;
            return Center(
              child: Text(
                state.message ??
                    'حدث خطأ أثناء تحميل سجل التاي. الرجاء المحاولة مرة أخرى.',
                style: TextStyles.getSize16(
                  color: AppColors.accentColor.withValues(alpha: 0.45),
                ),
              ),
            );
          } else if (state is HistoryLoadedState) {
            isLoading = false;
            historyList = state.historyList ?? [];
          }
          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  24,
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
                    Row(
                      children: [
                        CustomBackButton(),

                        const Gap(12),
                        Text(
                          widget.groupId != null
                              ? 'سجل نقاط المجموعة'
                              : 'سجل الطايو',

                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    // Summary pill
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
                            Icons.format_list_bulleted_rounded,
                            color: AppColors.whiteColor.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const Gap(8),
                          Text(
                            '${historyList.length} عملية',
                            style: TextStyles.getSize16(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              // ── List ──────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? SizedBox()
                    : historyList.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.07,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              size: 52,
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          const Gap(20),
                          Text(
                            widget.groupId != null
                                ? 'لا يوجد سجل لنقاط المجموعة حتى الآن'
                                : 'لا يوجد سجل للطايو حتى الآن',
                            textAlign: TextAlign.center,
                            style: TextStyles.getSize16(
                              color: AppColors.accentColor.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: historyList.length,
                        separatorBuilder: (_, __) => const Gap(10),
                        itemBuilder: (context, index) {
                          return TayoHistoryCard(item: historyList[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TayoHistoryCard extends StatelessWidget {
  const TayoHistoryCard({super.key, required this.item});

  final TayoHistoryModel item;

  bool get _isPositive => (item.change ?? 0) >= 0;

  Color get _accentColor => _isPositive ? AppColors.primaryColor : Colors.red;

  String _formatDate(DateTime dt) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} · $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stars, color: _accentColor, size: 20),
          ),
          const Gap(12),
          // Category / teacher / date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category ?? 'غير معروف',
                  style: TextStyles.getSize16(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.accentColor.withValues(alpha: 0.45),
                    ),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        item.teacherName ?? 'غير معروف',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.getSize16(
                          color: AppColors.accentColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.accentColor.withValues(alpha: 0.35),
                    ),
                    const Gap(4),
                    Text(
                      _formatDate(item.createdAt ?? DateTime.now()),
                      style: TextStyles.getSize12(
                        color: AppColors.accentColor.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(8),
          // Tayo change badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_isPositive ? '+' : ''}${item.change}',
              style: TextStyles.getSize16(
                color: _accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
