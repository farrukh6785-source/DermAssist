import 'package:flutter/material.dart';
import 'package:dermassist_fyp/splash_screen.dart';
import 'package:dermassist_fyp/login_screen.dart';
import 'package:dermassist_fyp/register_screen.dart';
import 'package:dermassist_fyp/main_screen.dart';
import 'package:dermassist_fyp/onboarding_screen.dart';
import 'package:dermassist_fyp/new_consultation_screen.dart';
import 'package:dermassist_fyp/image_quality_screen.dart';
import 'package:dermassist_fyp/symptom_input_screen.dart';
import 'package:dermassist_fyp/analysis_loading_screen.dart';
import 'package:dermassist_fyp/results_screen.dart';
import 'package:dermassist_fyp/pdf_report_screen.dart';
import 'package:dermassist_fyp/consultation_details_screen.dart';
import 'package:dermassist_fyp/provider_search_screen.dart';
import 'package:dermassist_fyp/edit_profile_screen.dart';
import 'package:dermassist_fyp/change_password_screen.dart';
import 'package:dermassist_fyp/privacy_settings_screen.dart';
import 'package:dermassist_fyp/about_screen.dart';
import 'package:dermassist_fyp/settings_screen.dart';
import 'package:dermassist_fyp/error_screen.dart';
//import 'package:dermassist_fyp/no_internet_screen.dart';

class AppRouter{
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main'; //Dashboard
  static const String newConsultation = '/new_consultation';
  static const String imageQuality = '/image_quality';
  static const String symptomInput = '/symptom_input';
  static const String analysisLoading = '/analysis_loading';
  static const String results = '/results';
  static const String pdfReport = '/pdf_Report';
  static const String consultationDetails = '/consultation_details';
  static const String providerSearch = '/provider_search';
  static const String editProfile = '/edit_profile';
  static const String changePassword = '/change_password';
  static const String privacySettings = '/privacy_settings';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String noInternet = '/no_internet';
  static const String error = '/error';


static Route<dynamic> generateRoute(RouteSettings settings){
  MaterialPageRoute buildRoute(Widget screen){
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
      );
  }
  try{
    switch(settings.name){
      case splash:
        return buildRoute(const SplashScreen());
      case onboarding:
        return buildRoute(const OnboardingScreen());
      case login:
        return buildRoute(const LoginScreen());
      case register:
        return buildRoute(const RegistrationScreen());
      case main:
        return buildRoute(const MainScreen());
      case newConsultation:
        return buildRoute( NewConsultationScreen());
      case imageQuality:
      // In real app, args like the image file would be passed here
        final args = settings.arguments as Map<String, dynamic>? ??{};
        return buildRoute(ImageQualityValidationScreen(imagePath:args['imagePath']));
      case symptomInput:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return buildRoute(SymptomInputScreen(imageUrl: args['imageUrl']));
      case analysisLoading:
        //final args = settings.arguments as Map<String, dynamic>? ?? {};
        //return buildRoute(AnalysisLoadingScreen(consultationData: args['consultationData']));
        return MaterialPageRoute(builder: (_) => const AnalysisLoadingScreen(),
          settings: settings
          );
        
      case results:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return buildRoute(ResultsDiagnosisScreen(resultData: args ['result']));
      case pdfReport:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return buildRoute(const PDFReportScreen());
      case consultationDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return buildRoute(const ConsultationDetailsScreen());
      case providerSearch:
        return buildRoute(const HealthcareProviderSearchScreen());
      case editProfile:
        return buildRoute(const EditProfileScreen());
      case changePassword:
        return buildRoute(const ChangePasswordScreen());
      case privacySettings:
        return buildRoute(const PrivacySettingsScreen());
      case about:
        return buildRoute(const AboutHelpScreen());
      case AppRouter.settings:
        return buildRoute(const SettingsScreen());
      case noInternet:
        return buildRoute(const NoInternetConnectionScreen());
      case error:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return buildRoute(ErrorScreen(message: args['message']));      
      default:
        return buildRoute(ErrorScreen(message: 'Route not found: ${settings.name}'));
      }
}catch(e){
  // Fallback for navigaton error
      return buildRoute(ErrorScreen(message: 'Navigator Error: $e'));
  }
}
}