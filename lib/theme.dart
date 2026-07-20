import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme{
  // Light Theme
  static ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        background: AppConstants.backgroundLight,
        surface: Colors.white,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppConstants.textPrimaryLight,
        onSurface: AppConstants.textPrimaryLight,
      ),
      textTheme: GoogleFonts.gloockTextTheme().copyWith(
        displayLarge: const TextStyle(color: AppConstants.textPrimaryLight, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: AppConstants.textPrimaryLight, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: AppConstants.textPrimaryLight, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color:AppConstants.textPrimaryLight, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: AppConstants.textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppConstants.textPrimaryLight),
        bodyMedium: const TextStyle(color: AppConstants.textSecondaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity,56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade100),

      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppConstants.borderRadius),
        ),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppConstants.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Gloock',
        ),
      ),
      bottomNavigationBarTheme:const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  // Dark Theme
  static ThemeData get darkTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        background: AppConstants.backgroundDark,
        surface: const Color(0xFF1E293B),
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: AppConstants.textPrimaryDark,
        onSurface: AppConstants.textPrimaryDark,
      ),
      textTheme: GoogleFonts.gloockTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: AppConstants.textPrimaryDark, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: AppConstants.textPrimaryDark, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: AppConstants.textPrimaryDark, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color:AppConstants.textPrimaryDark, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: AppConstants.textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppConstants.textPrimaryDark),
        bodyMedium: const TextStyle(color: AppConstants.textSecondaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity,56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.secondaryColor, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.secondaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        hintStyle: TextStyle(color: Color (0xFF64748B)),

      ),
      cardTheme: CardThemeData(
        color:const Color(0xFF1E293B),
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppConstants.borderRadius),
        ),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppConstants.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Gloock',
        ),
      ),
      bottomNavigationBarTheme:const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}