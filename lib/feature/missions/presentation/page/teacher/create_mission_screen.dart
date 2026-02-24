import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/form_field.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class CreateMissionScreen extends StatelessWidget {
  const CreateMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MainButton(onPressed: () {}, title: 'حفظ'),
      ),
      body: Column(
        children: [
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10),
                CustomBackButton(),
                Gap(15),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_rounded,
                        color: AppColors.whiteColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'إنشاء مهمة جديدة',
                      style: TextStyles.getSize24(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(5),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomFormField(
                  label: 'العنوان',
                  icon: Icons.label_rounded,
                  child: CustomTextField(
                    controller: TextEditingController(),
                    hintText: 'عنوان المهمة',
                  ),
                ),
                Gap(15),
                CustomFormField(
                  label: 'محتوى المهمة',
                  icon: Icons.description,
                  child: CustomTextField(
                    controller: TextEditingController(),
                    hintText: 'محتوى المهمة',
                    maxLines: 3,
                  ),
                ),
                Gap(15),
                CustomFormField(
                  label: 'المكافأة',
                  icon: Icons.emoji_events_rounded,
                  child: CustomTextField(
                    controller: TextEditingController(),
                    hintText: 'المكافأة',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
