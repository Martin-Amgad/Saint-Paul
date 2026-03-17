import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/custom_back_button.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/components/inputs/form_field.dart';
import 'package:saint_paul/core/extentions/app_regex.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/mission_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_cubit.dart';
import 'package:saint_paul/feature/missions/presentation/cubit/mission_state.dart';

class CreateAndEditMissionScreen extends StatefulWidget {
  const CreateAndEditMissionScreen({super.key, this.missionEdit});
  final MissionModel? missionEdit;

  @override
  State<CreateAndEditMissionScreen> createState() =>
      _CreateAndEditMissionScreenState();
}

class _CreateAndEditMissionScreenState
    extends State<CreateAndEditMissionScreen> {
  final List<String> items = ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'];

  @override
  void initState() {
    if (widget.missionEdit != null) {
      context.read<MissionCubit>().loadMissionControllers(widget.missionEdit);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<MissionCubit>();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MainButton(
          onPressed: () {
            if (cubit.formKey.currentState!.validate()) {
              if (widget.missionEdit == null) {
                cubit.createMission();
              } else {
                cubit.updateMission(
                  widget.missionEdit!.copyWith(
                    title: cubit.titleController.text,
                    description: cubit.descriptionController.text,
                    link: cubit.linkController.text,
                    reward: cubit.rewardController.text,
                    expireAfter:
                        int.tryParse(cubit.expireAfterController.text) ?? 0,
                    currentDate: DateTime.now(),
                  ),
                );
              }
            }
          },
          title: 'حفظ',
        ),
      ),
      body: SingleChildScrollView(
        child: BlocListener<MissionCubit, MissionState>(
          listener: (context, state) {
            if (state is MissionErrorState) {
              showMyDialoge(context, state.message, type: DialogType.error);
            } else if (state is MissionSuccessState) {
              pop(context);
              showMyDialoge(
                context,
                state.message ?? 'تم إنشاء المهمة بنجاح',
                type: DialogType.success,
              );
              pop(context);
            } else if (state is MissionLoadingState) {
              showLoadingDialog(context);
            }
          },
          child: Form(
            key: cubit.formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 6,
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
                      CustomBackButton(),
                      Gap(20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.15,
                              ),
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
                        label: 'المرحلة الدراسية',
                        icon: Icons.school_rounded,
                        child: DropdownButtonFormField<String>(
                          isDense: false,
                          value: cubit.selectedValue,
                          hint: Text(
                            'اختر المرحلة الدراسية',
                            style: TextStyles.getSize16(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamily: 'Cairo'),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryColor,
                          ),
                          dropdownColor: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          style: TextStyles.getSize16(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 3,
                            ),
                          ),
                          selectedItemBuilder: (context) {
                            return items.map((item) {
                              return Text(
                                item,
                                style: TextStyles.getSize16(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(fontFamily: 'Cairo'),
                              );
                            }).toList();
                          },

                          items: items.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyles.getSize16(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w500,
                                ).copyWith(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => cubit.selectedValue = value);
                          },
                        ),
                      ),
                      Gap(15),
                      CustomFormField(
                        label: 'العنوان',
                        icon: Icons.label_rounded,
                        child: CustomTextField(
                          controller: cubit.titleController,
                          hintText: 'عنوان المهمة',
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'الرجاء ادخال عنوان المهمة';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(15),
                      CustomFormField(
                        label: 'محتوى المهمة',
                        icon: Icons.description_rounded,
                        child: CustomTextField(
                          controller: cubit.descriptionController,
                          hintText: 'محتوى المهمة',
                          maxLines: 3,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'الرجاء ادخال محتوى المهمة';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(15),
                      CustomFormField(
                        label: 'اللينك (اختياري)',
                        icon: Icons.add_link_rounded,
                        child: CustomTextField(
                          controller: cubit.linkController,
                          hintText: 'اللينك ',
                        ),
                      ),
                      Gap(15),
                      CustomFormField(
                        label: 'المكافأة',
                        icon: Icons.emoji_events_rounded,
                        child: CustomTextField(
                          controller: cubit.rewardController,
                          hintText: 'المكافأة',
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'الرجاء ادخال المكافأة';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(15),
                      CustomFormField(
                        label: 'مدة المهمة (بالأيام)',
                        icon: Icons.emoji_events_rounded,
                        child: CustomTextField(
                          controller: cubit.expireAfterController,
                          hintText: 'مدة المهمة',
                          isPhone: true,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'الرجاء ادخال مدة المهمة';
                            } else if (!AppRegex.isValidInt(p0)) {
                              return 'الرجاء ادخال رقم صالح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
