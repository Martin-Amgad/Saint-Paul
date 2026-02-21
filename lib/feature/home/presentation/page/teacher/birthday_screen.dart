import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  bool isLoading = true;

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];

  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await FirebaseProvider.sortStudentsByBirthday();

    allStudents = snapshot.docs
        .map(
          (doc) =>
              StudentModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    filteredStudents = List.from(allStudents);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   backgroundColor: AppColors.surfaceColor,
      //   elevation: 0,
      //   title: Text(
      //     'اعياد ميلاد الطلاب',
      //     style: TextStyles.getSize24(
      //       color: AppColors.primaryColor,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'أعياد الميلاد',
                          style: TextStyles.getSize24(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Spacer(flex: 4),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: DropdownButtonFormField<String>(
                            // isExpanded: true,
                            focusColor: AppColors.primaryColor,
                            iconEnabledColor: AppColors.whiteColor,
                            dropdownColor: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            value: selectedMonth,
                            hint: Text(
                              " اختر الشهر",
                              style: TextStyles.getSize16(
                                color: AppColors.whiteColor,
                              ),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.primaryColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items:
                                [
                                      "يناير",
                                      "فبراير",
                                      "مارس",
                                      "أبريل",
                                      "مايو",
                                      "يونيو",
                                      "يوليو",
                                      "أغسطس",
                                      "سبتمبر",
                                      "أكتوبر",
                                      "نوفمبر",
                                      "ديسمبر",
                                    ]
                                    .map(
                                      (month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(
                                          month,
                                          style: TextStyles.getSize16(
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                              });
                            },
                          ),
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                    // SizedBox(
                    //       width: 200,
                    //       child: DropdownButtonFormField<String>(
                    //         focusColor: AppColors.primaryColor,
                    //         iconEnabledColor: AppColors.whiteColor,
                    //         dropdownColor: AppColors.primaryColor,
                    //         borderRadius: BorderRadius.circular(12),
                    //         value: selectedMonth,
                    //         hint: Text(
                    //           " اختر الشهر",
                    //           style: TextStyles.getSize16(
                    //             color: AppColors.whiteColor,
                    //           ),
                    //         ),
                    //         decoration: InputDecoration(
                    //           filled: true,
                    //           fillColor: AppColors.primaryColor,
                    //           contentPadding: EdgeInsets.symmetric(
                    //             horizontal: 16,
                    //             vertical: 12,
                    //           ),
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //             borderSide: BorderSide.none,
                    //           ),
                    //         ),
                    //         items:
                    //             [
                    //                   "يناير",
                    //                   "فبراير",
                    //                   "مارس",
                    //                   "أبريل",
                    //                   "مايو",
                    //                   "يونيو",
                    //                   "يوليو",
                    //                   "أغسطس",
                    //                   "سبتمبر",
                    //                   "أكتوبر",
                    //                   "نوفمبر",
                    //                   "ديسمبر",
                    //                 ]
                    //                 .map(
                    //                   (month) => DropdownMenuItem(
                    //                     value: month,
                    //                     child: Text(
                    //                       month,
                    //                       style: TextStyles.getSize16(
                    //                         color: AppColors.whiteColor,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 )
                    //                 .toList(),
                    //         onChanged: (value) {
                    //           setState(() {
                    //             selectedMonth = value;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    Gap(24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredStudents.length, // عدد المعلمين
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.05,
                                  ),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: 24,
                                child: Text(
                                  'م${index + 1}',
                                  style: TextStyles.getSize16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                filteredStudents[index].name ??
                                    'المعلم ${index + 1}',
                                style: TextStyles.getSize16(
                                  color: AppColors.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'تاريخ الميلاد: ${filteredStudents[index].dob ?? "غير محدد"}',
                                  style: TextStyles.getSize12(
                                    color: AppColors.textSecondaryColor,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                Icons.cake_outlined,
                                color: AppColors.accentColor,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
