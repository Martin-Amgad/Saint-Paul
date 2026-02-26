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

  var searchController = TextEditingController();
  String searchText = '';

  // Month names in order for the chip row
  static const List<String> months = [
    "الكل",
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
  ];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() => isLoading = true);

    final snapshot = await FirebaseProvider.fetchStudentsByBirthday();

    allStudents = snapshot.docs
        .map(
          (doc) =>
              StudentModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    filteredStudents = List.from(allStudents);
    filteredStudents.sort((a, b) {
      if (a.birthday == null && b.birthday == null) return 0;
      if (a.birthday == null) return 1;
      if (b.birthday == null) return -1;
      return a.birthday!.month.compareTo(b.birthday!.month);
    });

    setState(() {
      if (context.mounted) isLoading = false;
    });
  }

  bool birthdayInAWeek(DateTime? birthday) {
    if (birthday == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inAWeek = today.add(const Duration(days: 7));
    final birthdayThisYear = DateTime(now.year, birthday.month, birthday.day);
    return !birthdayThisYear.isBefore(today) &&
        !birthdayThisYear.isAfter(inAWeek);
  }

  void onMonthSelected(String month) {
    setState(() {
      selectedMonth = month;
      if (month == "الكل") {
        filteredStudents = List.from(allStudents);
        filteredStudents.sort((a, b) {
          if (a.birthday == null && b.birthday == null) return 0;
          if (a.birthday == null) return 1;
          if (b.birthday == null) return -1;
          return a.birthday!.month.compareTo(b.birthday!.month);
        });
        return;
      }
      filteredStudents = allStudents
          .where((s) => s.birthday?.month == monthMapping[month])
          .toList();
      filteredStudents.sort((a, b) {
        if (a.birthday == null && b.birthday == null) return 0;
        if (a.birthday == null) return 1;
        if (b.birthday == null) return -1;
        return a.birthday!.day.compareTo(b.birthday!.day);
      });
    });
  }

  String formatBirthday(DateTime? dt) {
    if (dt == null) return '—';
    return ' ${dt.month} / ${dt.day} ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              20,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cake_rounded,
                        color: AppColors.yellowIconColor,
                        size: 26,
                      ),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أعياد الميلاد',
                          style: TextStyles.getSize24(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'المخدومون المحتفلون قريباً',
                          style: TextStyles.getSize12(
                            color: AppColors.whiteColor.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(18),
                // Month chips in a horizontal scroll
                SizedBox(height: 36, child: monthChipBuilder()),
              ],
            ),
          ),

          const Gap(16),

          // ── Count label ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  selectedMonth == null || selectedMonth == "الكل"
                      ? 'الكل'
                      : selectedMonth!,
                  style: TextStyles.getSize18(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredStudents.length}',
                    style: TextStyles.getSize12(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(12),

          // ── List ─────────────────────────────────────────────
          isLoading
              ? Column(
                  children: [
                    Gap(MediaQuery.of(context).size.height * 0.26),
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                )
              : Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                size: 64,
                                color: AppColors.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'لا يوجد مخدومون في هذا الشهر',
                                style: TextStyles.getSize16(
                                  color: AppColors.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              final birthday = student.birthday;
                              final isInAWeek = selectedMonth != null
                                  ? birthdayInAWeek(birthday)
                                  : false;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isInAWeek
                                      ? const Color(
                                          0xFF22C55E,
                                        ).withValues(alpha: 0.08)
                                      : AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isInAWeek
                                        ? const Color(
                                            0xFF22C55E,
                                          ).withValues(alpha: 0.5)
                                        : AppColors.primaryColor.withValues(
                                            alpha: 0.1,
                                          ),
                                    width: isInAWeek ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isInAWeek
                                          ? const Color(
                                              0xFF22C55E,
                                            ).withValues(alpha: 0.1)
                                          : Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                      blurRadius: isInAWeek ? 12 : 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar / cake icon
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isInAWeek
                                              ? const Color(
                                                  0xFF22C55E,
                                                ).withValues(alpha: 0.15)
                                              : AppColors.primaryColor
                                                    .withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isInAWeek
                                                ? const Color(
                                                    0xFF22C55E,
                                                  ).withValues(alpha: 0.4)
                                                : AppColors.primaryColor
                                                      .withValues(alpha: 0.15),
                                          ),
                                        ),
                                        child: Center(
                                          child: isInAWeek
                                              ? const Text(
                                                  '🎂',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                )
                                              : Text(
                                                  '${index + 1}',
                                                  style: TextStyles.getSize16(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const Gap(12),
                                      // Name & birthday
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name ?? 'بدون اسم',
                                              style: TextStyles.getSize16(
                                                color:
                                                    AppColors.textPrimaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Gap(3),
                                            Text(
                                              'تاريخ الميلاد: ${formatBirthday(birthday)}',
                                              style: TextStyles.getSize12(
                                                color: AppColors
                                                    .textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // "Soon" badge
                                      if (isInAWeek)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF22C55E,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            'قريباً 🎉',
                                            style: TextStyle(
                                              color: const Color(0xFF16A34A),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
        ],
      ),
    );
  }

  ListView monthChipBuilder() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: months.length,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, i) {
        final month = months[i];
        final isSelected =
            selectedMonth == month ||
            (month == "الكل" && selectedMonth == null);
        return GestureDetector(
          onTap: () => onMonthSelected(month),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.whiteColor
                  : AppColors.whiteColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              month,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.whiteColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}

Map<String, int> monthMapping = {
  "يناير": 1,
  "فبراير": 2,
  "مارس": 3,
  "أبريل": 4,
  "مايو": 5,
  "يونيو": 6,
  "يوليو": 7,
  "أغسطس": 8,
  "سبتمبر": 9,
  "أكتوبر": 10,
  "نوفمبر": 11,
  "ديسمبر": 12,
};
