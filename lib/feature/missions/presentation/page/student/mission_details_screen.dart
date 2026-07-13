import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/Custom_form_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/services/local/local_helper.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';
import 'package:saint_paul/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class MissionDetailsScreen extends StatefulWidget {
  const MissionDetailsScreen({
    super.key,
    required this.mission,
    this.isAvailable,
  });
  final MissionModel mission;
  final bool? isAvailable;

  @override
  State<MissionDetailsScreen> createState() => _MissionDetailsScreenState();
}

class _MissionDetailsScreenState extends State<MissionDetailsScreen> {
  final answerController = TextEditingController();

  int daysLeft(MissionModel m) {
    if (m.currentDate == null || m.expireAfter == null) return 0;
    final expireDate = m.currentDate!.add(Duration(days: m.expireAfter!));
    return expireDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    var reward = widget.mission.reward ?? '0';
    bool isRewardNumeric = AppRegex.containsOnlyNumbers(reward);
    var cubit = context.read<MissionCubit>();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),

        child: widget.isAvailable ?? false
            ? MainButton(
                title: 'قبول المهمة',
                onPressed: () {
                  cubit.acceptMission(widget.mission.mid ?? '');
                  cubit.fetchMissions();
                  cubit.updateMission(
                    widget.mission.copyWith(
                      enrolledStudents: widget.mission.enrolledStudents! + 1,
                    ),
                  );
                },
              )
            : null,
        // : MainButton(
        //     title: 'إرسال الحل',
        //     onPressed: () {
        //       if (_formKey.currentState!.validate()) {
        //         context.read<MissionCubit>().submitMission(
        //           widget.mission.mid ?? '',
        //           widget.mission.copyWith(
        //             studentSolution: answerController.text,
        //           ),
        //         );

        //         answerController.clear();
        //       }
        //     },
        //   ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<MissionCubit, MissionState>(
        listener: (context, state) {
          if (state is MissionErrorState) {
            showMyDialoge(context, state.message, type: DialogType.error);
          } else if (state is MissionSuccessState) {
            showMyDialoge(
              context,
              state.message ?? "تم قبول المهمة بنجاح",
              type: DialogType.success,
            );
            pop(context);
            context.read<ProfileCubit>().loadStudentData(
              LocalHelper.getUserId(),
            );
          }
        },
        child: Column(
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
                          widget.mission.title ?? 'مهمة',
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
                      color: AppColors.darkYellowIconColor.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.darkYellowIconColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.darkYellowIconColor,
                          size: 18,
                        ),
                        const Gap(6),
                        Text(
                          isRewardNumeric
                              ? 'المكافأة: $reward طايو'
                              : 'المكافأة: $reward',
                          style: TextStyles.getSize16(
                            color: AppColors.darkYellowIconColor,
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
                        widget.mission.description ?? 'لا يوجد وصف',
                        style: TextStyles.getSize16(
                          color: AppColors.accentColor.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    const Gap(15),

                    // Link card — only if link exists
                    if ((widget.mission.link ?? '').isNotEmpty)
                      _SectionCard(
                        icon: Icons.link_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        label: 'الرابط',
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(widget.mission.link!));
                                },
                                child: Text(
                                  widget.mission.link!,
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
                    Gap(15),
                    _SectionCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: 'مدة المهمة',
                      child: Text(
                        widget.mission.expireAfter != null
                            ? 'تنتهي بعد ${daysLeft(widget.mission)} يوم'
                            : 'لا يوجد تاريخ انتهاء',
                        style: TextStyles.getSize16(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Gap(15),
                    // _SectionCard(
                    //   icon: Icons.check_circle_outline_rounded,
                    //   iconColor: const Color(0xFF8B5CF6),
                    //   label: 'حل المهمة',
                    //   child: Form(
                    //     key: _formKey,
                    //     child: widget.isAvailable ?? false
                    //         ? Gap(0)
                    //         : CustomTextField(
                    //             hintText: 'اكتب حل المهمة...',
                    //             maxLines: 5,
                    //             controller: answerController,
                    //             validator: (p0) {
                    //               if (p0 == null || p0.trim().isEmpty) {
                    //                 return 'يرجى كتابة حل المهمة';
                    //               }
                    //               return null;
                    //             },
                    //           ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
