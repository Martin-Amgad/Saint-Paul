import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_cubit.dart';
import 'package:saint_paul/feature/home/presentation/cubit/home_state.dart';

void removeCommonElements(
  List<String> tayoNewCategories,
  List<String> tayoRemovedCategories,
) {
  final set1 = tayoNewCategories.toSet();
  final set2 = tayoRemovedCategories.toSet();

  final common = set1.intersection(set2);

  tayoNewCategories.removeWhere((item) => common.contains(item));
  tayoRemovedCategories.removeWhere((item) => common.contains(item));
}

class StudentDetailsScreen extends StatefulWidget {
  StudentDetailsScreen({super.key, required this.student});
  final StudentModel student;

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic> tayo = {};
  List<String> tayoNewCategories = [];
  List<String> tayoRemovedCategories = [];
  final tayoCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeCubit>();
    cubit.getStudentTayoDetails(widget.student);
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<HomeCubit>();

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MainButton(
                  title: 'اضف بند جديد',
                  onPressed: () {
                    addNewTayoItemBottomSheet(context);
                  },
                  bgcolor: AppColors.secondaryColor,
                  textColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor.withValues(alpha: 0.5),
                ),
                Gap(10),
                MainButton(
                  title: 'تاكيد',
                  onPressed: () {
                    removeCommonElements(
                      tayoNewCategories,
                      tayoRemovedCategories,
                    );
                    cubit.updateStudent(
                      widget.student.copyWith(
                        tayo: tayo,
                        totalTayo: computeTotalTayo(),
                      ),
                      tayoNewCategories,
                      tayoRemovedCategories,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'معلومات المخدوم',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: () {
            pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingState) {
            showLoadingDialog(context);
          } else if (state is HomeErrorState) {
            pop(context);
            showMyDialoge(context, state.message, type: DialogType.error);
          } else if (state is HomeSuccessState) {
            pop(context);
            showMyDialoge(
              context,
              'تم تحديث بيانات المخدوم بنجاح',
              type: DialogType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is HomeErrorState) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          } else if (state is HomeTayoLoadSuccessState && tayo.isEmpty) {
            tayo = state.tayo;
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاسم: ${widget.student.name}',
                      style: TextStyles.getSize24(fontWeight: FontWeight.w600),
                    ),
                    Gap(25),
                    Text(
                      'مجموع الطايو :${computeTotalTayo()}',
                      style: TextStyles.getSize18(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    Gap(25),
                    Text(
                      'توزيعه الطايوهات',
                      style: TextStyles.getSize18(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Gap(10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tayo.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Gap(10);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final key = tayo.keys.toList()[index];
                        final value = tayo[key];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.borderColor.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key, style: TextStyles.getSize18()),
                                    IconButton(
                                      onPressed: () {
                                        log('Removing category: $key');
                                        tayo.remove(key);

                                        tayoRemovedCategories.add(key);

                                        log(
                                          'removed categories after removal: ${tayoRemovedCategories.toList()}',
                                        );
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        tayo[key] = value + 1;
                                        log(tayo[key].toString());
                                        setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(28, 28),
                                        padding: EdgeInsets.zero,
                                        backgroundColor: AppColors.primaryColor
                                            .withValues(alpha: 1.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Icon(Icons.add),
                                    ),
                                    Text(
                                      value.toString(),
                                      style: TextStyles.getSize18(),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (value > 0) {
                                          tayo[key] = value - 1;
                                        }
                                        log(tayo[key].toString());
                                        setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(28, 28),
                                        padding: EdgeInsets.zero,
                                        backgroundColor: AppColors.primaryColor
                                            .withValues(alpha: 1.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Icon(Icons.remove),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  addNewTayoItemBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tayoCategoryController,
                      decoration: InputDecoration(
                        hintText: 'اسم بند الطايو الجديد',
                      ),
                    ),
                    Gap(15),
                    MainButton(
                      title: 'اضف بند الطايو الجديد',
                      onPressed: () {
                        setState(() {
                          tayo[tayoCategoryController.text] = 0;
                          tayoNewCategories.add(tayoCategoryController.text);
                          log(
                            'new categories after addition: ${tayoNewCategories.toList()}',
                          );
                          setState(() {});
                          tayoCategoryController.clear();
                          pop(context);
                        });
                      },
                    ),
                    Gap(15),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  computeTotalTayo() {
    int totalTayo = 0;
    tayo.forEach((key, value) {
      totalTayo += value as int;
    });
    return totalTayo;
  }
}
