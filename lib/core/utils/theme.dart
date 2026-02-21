import 'package:flutter/material.dart';
import 'package:saint_paul/core/utils/colors.dart';
import 'package:saint_paul/core/utils/text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',

    // 🌿 Background
    scaffoldBackgroundColor: AppColors.backgroundColor,

    // 🎨 Color Scheme (fully aligned)
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.whiteColor,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.primaryColor,
      surface: AppColors.surfaceColor,
      onSurface: AppColors.textPrimaryColor,
      error: AppColors.primaryColor,
      onError: AppColors.whiteColor,
      outline: AppColors.borderColor,
      background: AppColors.backgroundColor,
      onBackground: AppColors.textPrimaryColor,
    ),

    // 🏛 AppBar
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.backgroundColor,
      foregroundColor: AppColors.primaryColor,
      iconTheme: const IconThemeData(color: AppColors.primaryColor),
      titleTextStyle: TextStyles.getSize16(
        color: AppColors.primaryColor,
        fontSize: 20,
      ),
    ),

    // ✍️ Text Buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // 📝 Input Fields (fixed)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColor, // softer than gold
      hintStyle: TextStyles.getSize16(color: AppColors.greyColor),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    ),

    // 🔘 Elevated Buttons (global style)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // 📱 Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.greyColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),

    // 🪪 Cards
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
