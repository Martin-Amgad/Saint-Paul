import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saint_paul/components/buttons/main_button.dart';
import 'package:saint_paul/components/inputs/custom_text_field.dart';
import 'package:saint_paul/core/constants/app_assets.dart';
import 'package:saint_paul/core/extentions/dialogs.dart';
import 'package:saint_paul/core/models/student_model.dart';
import 'package:saint_paul/core/routes/navigation.dart';
import 'package:saint_paul/core/routes/routes.dart';
import 'package:saint_paul/core/services/firebase/firebase_provider.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  var searchController = TextEditingController();
  var nameController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الصفحة الرئيسية',
          style: TextStyles.getSize24(
            color: AppColors.accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            addNewStudentBottomSheet(context);
            // for (var item in items) {
            //   FirebaseProvider.createStudent(StudentModel(name: item));
            // }
          },
          icon: const Icon(Icons.add),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSignOutDialog(context);
            },
            icon: SvgPicture.asset(
              AppAssets.logoutSvg,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.accentColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseProvider.studentCollection
            .orderBy('totalTayo', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطا في تحميل المخدومين',
                style: TextStyles.getSize18(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allStudents = docs
              .map(
                (doc) => StudentModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          final filteredStudents = searchText.isEmpty
              ? allStudents
              : allStudents.where((student) {
                  final name = student.name ?? '';
                  return name.contains(searchText);
                }).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: searchController,
                      hintText: "بحث",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: SvgPicture.asset(
                          AppAssets.searchSvg,
                          colorFilter: ColorFilter.mode(
                            AppColors.accentColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: Icon(Icons.close, color: AppColors.accentColor),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.trim();
                        });
                      },
                    ),
                    Gap(20),
                    Text(
                      'المخدومون',
                      style: TextStyles.getSize24(
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(20),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.8, //0.8 if circle avatar
                          //put this before text in a column if you want circle avatar
                          // Gap(20),
                          // CircleAvatar(
                          //   radius: itemWidth * 0.3,
                          //   backgroundColor: AppColors.primaryColor
                          //       .withValues(alpha: 0.5),
                          //   child: CircleAvatar(
                          //     radius: itemWidth * 0.25,
                          //     backgroundImage: NetworkImage(
                          //       'https://res.cloudinary.com/dltddu8ah/image/upload/v1764722376/defaultUser_d0jch4.png',
                          //     ),
                          //   ),
                          // ),
                          // Gap(10),
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (BuildContext context, int index) {
                          double itemWidth =
                              (MediaQuery.of(context).size.width -
                                  20 * 2 -
                                  15) /
                              2;
                          double itemHeight = itemWidth * 10;
                          return GestureDetector(
                            onTap: () {
                              pushTo(
                                context,
                                Routes.studentDetailsScreen,
                                extra: filteredStudents[index],
                              );
                            },
                            child: Container(
                              height: itemHeight + 100,

                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        filteredStudents[index].name ??
                                            'No Name',
                                        style: TextStyles.getSize18(
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: itemWidth * 0.1,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),

                                      Text(
                                        ' مجموع الطايو :  ${filteredStudents[index].totalTayo ?? 0}',
                                        style: TextStyles.getSize18(
                                          color: AppColors.accentColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: itemWidth * 0.1,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
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
        },
      ),
    );
  }

  void addNewStudentBottomSheet(BuildContext context) {
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
                    TextField(controller: nameController),
                    Gap(15),
                    MainButton(
                      title: 'اضف مخدوم',
                      onPressed: () async {
                        await FirebaseProvider.createStudent(
                          StudentModel(name: nameController.text),
                        );
                        nameController.clear();
                        searchController.clear();
                        setState(() {
                          searchText = '';
                        });
                        if (context.mounted) {
                          pop(context);
                        }
                      },
                    ),
                    Gap(10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// List<String> items = [
//   "ابرام امين عزت عبد الساتر",
//   "ارميا الفريد بشرى اسكندر",
//   "انطونى ثروت يوسف ابراهيم",
//   "انطونيوس عصمت أنور متري",
//   "أبانوب ايمن جبرائيل شكرى",
//   "أبانوب رضا لطفى نوار",
//   "أبانوب نجيب نبيل نجيب",
//   "أبانوب وجدي موسي",
//   "أرسانى عيسى صدقى خميس بخيبت",
//   "أستيفن عماد جورج غبريال عوض",
//   "أمير هانى امير فكري",
//   "بافلى باسم وهيب عزيز",
//   "بافلى سامح اسحق اسكندر",
//   "بافلى عصام منير حنا",
//   "بطرس مينا ناصف بخيت",
//   "بولا توما روماني فؤاد",
//   "بولا عريان رفعت محروس",
//   "بولا هانى نبيل",
//   "بولا هانى صبحى شنودة",
//   "بيشوي إيليا عبده عزيز",
//   "جرجس فوزى عبدالسيد عبد السيد",
//   "جورج اشرف ميخائيل غطاس",
//   "جورج جمال منصور حلقه شنودة",
//   "جوفانى لوقا زخارى بطرس",
//   "جيوفاني نادر نزيه شفيق",
//   "دانيال صدام أيوب سمعان",
//   "ديفيد ميشيل داوود حنا عوض",
//   "ديفيد هانى سامى جرجس",
//   "روجيه رامز جوزيف",
//   "رومانى عزيز",
//   "رومانى وحيد عطالله شحاته",
//   "سعد هانى سعد",
//   "شادى البير شفيق",
//   "شريف اشرف هلال",
//   "شنودة طارق وديع",
//   "فادى نادى عاطف",
//   "فيلوباتير رومانى زاخر شاكر",
//   "فيلوباتير رومانى سيد مسعد",
//   "فيلوباتير عماد فاروق",
//   "فيلوباتير مايكل وليم رياض",
//   "فيلوباتير ملاك ذكى",
//   "كاراس جميل صباح",
//   "كاراس جورج حلمى ذكى",
//   "كاراس عماد شوقى",
//   "كاراس كرم ذكى بيشاي",
//   "كاراس ماجد فوزي لبيب",
//   "كاراس مدحت عياد برسوم",
//   "كاراس هانى برنس غطاس",
//   "كريم حاتم زكريا امين",
//   "كيرلس اسحق شوقى حكيم",
//   "كيرلس ثروت وليم توفيق",
//   "كيرلس عادل حنين عبد الملك",
//   "كيرلس رضا",
//   "كيرلس جمال حسني عبد المسيح",
//   "مارتن مايكل منصور",
//   "مارتن ميشيل",
//   "مارتينوس مينا سامى نجيب",
//   "مارسلينو مايكل توفيق",
//   "مارك حربى",
//   "مارك فادي علوت",
//   "مايكل صبور عطالله",
//   "مايكل ماجد شحاته",
//   "مايكل ملاك موسى",
//   "ميلاتيوس امجد صموئيل",
//   "مينا سفين رضاني فرح",
//   "مينا عاطف فايز صليب",
//   "مينا مكرم رزق يعقوب",
//   "مينا هاني سمير",
//   "يوساب شفيق سعيد عازر",
//   "يوساب نادر إبراهيم",
//   "يوسف ألياس",
//   "يوسف برسوم محفوظ",
//   "يوسف جورج يوسف",
//   "يوسف زكريا إيليا لمعي",
//   "يوسف شريف نبيل وليم",
//   "يوسف فوزى معوض",
//   "يوسف ندير ماهر",
// ];
