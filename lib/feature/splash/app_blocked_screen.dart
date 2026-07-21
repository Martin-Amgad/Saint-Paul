import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppBlockedReason { update, maintenance }

class AppBlockedScreen extends StatelessWidget {
  const AppBlockedScreen({
    super.key,
    required this.reason,
    required this.appDownloadUrl,
  });

  final AppBlockedReason reason;
  final String appDownloadUrl;

  bool get _isUpdate => reason == AppBlockedReason.update;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(25),
                Text(
                  _isUpdate ? 'التطبيق يحتاج إلى تحديث' : 'التطبيق تحت الصيانة',
                  style: TextStyles.getSize30(
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                  ),
                ),
                const Gap(6),
                Text(
                  _isUpdate
                      ? 'يرجى التحديث للمتابعة'
                      : 'نعمل على تحسين التطبيق، نعود قريبًا',
                  style: TextStyles.getSize16(
                    color: AppColors.whiteColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isUpdate
                          ? Icons.system_update_alt_rounded
                          : Icons.build_outlined,
                      size: _isUpdate ? 52 : 60,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  const Gap(24),

                  Text(
                    _isUpdate
                        ? 'نسخة محدّثة جاهزة للتنزيل'
                        : 'نعتذر عن هذا الانقطاع',
                    textAlign: TextAlign.center,
                    style: TextStyles.getSize18(
                      fontSize: _isUpdate ? 18 : 20,
                      color: AppColors.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Gap(12),

                  Text(
                    _isUpdate
                        ? 'التحديث ضروري لضمان أفضل أداء\nواستقرار للتطبيق.'
                        : 'التطبيق غير متاح مؤقتًا بسبب أعمال الصيانة.\nسنعود في أقرب وقت ممكن.',
                    textAlign: TextAlign.center,
                    style: TextStyles.getSize16(
                      fontSize: _isUpdate ? 14 : 16,

                      color: AppColors.textSecondaryColor,
                    ),
                  ),

                  const Gap(30),

                  if (_isUpdate)
                    MainButton(
                      title: 'تحديث التطبيق',
                      onPressed: () {
                        launchUrl(
                          Uri.parse(appDownloadUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
