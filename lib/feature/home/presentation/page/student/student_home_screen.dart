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

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  var searchController = TextEditingController();
  var nameController = TextEditingController();
  String searchText = '';

  bool isLoading = true;

  List<StudentModel> allStudents = [];
  List<StudentModel> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await FirebaseProvider.sortStudentsByTotalTayo();

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                              filteredStudents = List.from(allStudents);
                            });
                          },
                          icon: Icon(Icons.close, color: AppColors.accentColor),
                        ),
                        onChanged: (value) {
                          final text = value.trim();

                          setState(() {
                            if (text.isEmpty) {
                              filteredStudents = List.from(allStudents);
                            } else {
                              filteredStudents = allStudents.where((student) {
                                final name = student.name ?? '';
                                return name.contains(text);
                              }).toList();
                            }
                          });
                        },
                      ),
                      Gap(20),
                      Text(
                        'المتصدرين',
                        style: TextStyles.getSize24(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(20),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //   crossAxisCount: 2,
                          //   mainAxisSpacing: 15,
                          //   crossAxisSpacing: 15,
                          //   childAspectRatio: 2.5, //0.8 if circle avatar
                          //   //put this before text in a column if you want circle avatar
                          //   // Gap(20),
                          //   // CircleAvatar(
                          //   //   radius: itemWidth * 0.3,
                          //   //   backgroundColor: AppColors.primaryColor
                          //   //       .withValues(alpha: 0.5),
                          //   //   child: CircleAvatar(
                          //   //     radius: itemWidth * 0.25,
                          //   //     backgroundImage: NetworkImage(
                          //   //       'https://res.cloudinary.com/dltddu8ah/image/upload/v1764722376/defaultUser_d0jch4.png',
                          //   //     ),
                          //   //   ),
                          //   // ),
                          //   // Gap(10),
                          // ),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (context, index) => Gap(15),
                          itemBuilder: (BuildContext context, int index) {
                            double itemWidth =
                                (MediaQuery.of(context).size.width -
                                    20 * 2 -
                                    15) /
                                2;

                            return Container(
                              width: itemWidth * 2 + 15,
                              height: 50,
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
                                  child: Row(
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
                                        maxLines: 1,
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Text(
                                          ' ${filteredStudents[index].totalTayo ?? 0}',
                                          style: TextStyles.getSize18(
                                            color: AppColors.accentColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: itemWidth * 0.1,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
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
            ),
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
