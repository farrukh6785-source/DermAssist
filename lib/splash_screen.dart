
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'providers/auth_provider.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  
@override
State<SplashScreen> createState()=> _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState(){
    super.initState();

    // Logo fade-in animation
    _controller = AnimationController(
      duration: const Duration(microseconds: 1500),
      vsync: this,
      );
      _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
      _controller.forward();

      // Chech auth status and navigate after delay
      _checkStatusAndNavigate();
  }
  Future<void> _checkStatusAndNavigate() async{
    await Future.delayed(const Duration(seconds: 3));
    if(!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding = prefs.getBool(AppConstants.prefsOnboardingComplete) ?? false;
    // Naviagtion logic based on state
    if(!hasCompletedOnboarding){
      Navigator.popAndPushNamed(context, AppRouter.onboarding);
    } else if(authProvider.isAuthenticated){
      Navigator.popAndPushNamed(context, AppRouter.main);
    } else{
      Navigator.popAndPushNamed(context, AppRouter.login);
    }
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppConstants.logo, height: 150,),
              const SizedBox(height: 24,),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displaySmall ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12,),
              Text("AI-Powered Dermatology Screening",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 64,),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
          ),
          ),
      ),
    );
  }
}