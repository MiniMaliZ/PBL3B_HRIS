import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (dari Salary Report)
  static const Color primaryDark = Color(0xFF2D4A6F);
  static const Color primaryMedium = Color(0xFF34567A);
  static const Color primaryLight = Color(0xFF5A7FA8);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF6B8FB5);
  static const Color secondaryLight = Color(0xFFB8C9DB);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF757575);

  // Accent Colors
  static const Color accent = Color(0xFF26A69A);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.background,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),

      // // Card Theme
      // cardTheme: CardTheme(
      //   color: AppColors.cardBackground,
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return null;
        }),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.secondaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.secondaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.secondaryLight),
          ),
        ),
      ),
    );
  }
}
