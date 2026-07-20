import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_gate.dart';

// Firebase configuration
import 'firebase_options.dart';

// Providers 
import 'providers/auth_provider.dart';
import 'providers/consultation_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/theme_provider.dart';

// App Router
import 'router.dart';

// Theme
import 'theme.dart';

void main() async{
  // Ensure Flutter binding is initialized before async call
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase with auto-generated options from google-services.json
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load shared preferences 
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(DermAssist(sharedPreferences:sharedPreferences,));
}

class DermAssist extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const DermAssist({super.key, required this.sharedPreferences});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider manages Firebase authentication state
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Theme provider manages light/dark mode
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(sharedPreferences),
          ),
          ChangeNotifierProvider(create: (_) => ConsultationProvider()),
          ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(Connectivity()),
        ),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _){
          return MaterialApp(
            title: 'DermAssist',
            debugShowCheckedModeBanner: false,

            // Apply custom theme based on user preference
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // Use standard Navigation generator
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      home: AuthGate(),
      
          );
        } ,
        ),
    );
  }
}