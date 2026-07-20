import 'package:flutter/material.dart';
class AppConstants{
  // App Info
  static const String appName = "DermAssist";
  static const String appVersion = "1.0.0";

  // SharedPreferences Keys
  static const String prefsOnboardingComplete = "onboarding_complete";
  static const String prefsThemeMode = "theme_mode";
  static const String prefsAuthToken = "auth_token";

  // Risk Levels Context
  static const String riskHigh = "High Risk";
  static const String riskMedium = "Medium Risk";
  static const String riskLow = "Low Risk";
  
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF38BDF8);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Semantic Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  
  // Risk Colors
  static const Color lowRiskColor = Color(0xFF10B981);
  static const Color highRiskColor = Color(0xFFEF4444);
  static const Color mediumRiskColor = Color(0xFFF59E0B);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dimension
  static const double borderRadius = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 8.0;

  // Limits
  static const int symptomDescMaxLength = 500;
  static const int maxImageSizeMB = 5;
  
  // assets
  static const String logo = 'assets/images/logo.png';
  static const String splashAnimation = 'assets/animations/splash.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String analyzingAnimation = 'assets/animations/analyzing.json';
  static const String errorAnimation = 'assets/animations/error.json';
}