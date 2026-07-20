import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';

class OnboardingScreen extends StatefulWidget{
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

}
class _OnboardingScreenState extends State<OnboardingScreen>{
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Wellcome to DermAssist",
      description: "Your intelligent assistant for early detection and screening of dermatological conditions.",
      icon: Icons.waving_hand_outlined,
    ),
    OnboardingData(
      title: "How It works",
      description: "Simply capture a clear photo of your skin lesion, answer a few syjptom questions and get an instant AI analysis.",
      icon: Icons.document_scanner_outlined,
    ),
    OnboardingData(
      title: "Expert Level AI",
      description: "Powered by advanced AI models to provide high-accuracy risk assessments and differential diagnoses.",
      icon: Icons.psychology_rounded,
    ),
    OnboardingData(
      title: "Privacy First",
      description: "Your health data is encrypted and securely stored. We prioritize your privacy and safety at every step.",
      icon: Icons.verified_user_rounded,
    ),
  ];
  Future<void> _completeOnboarding()async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefsOnboardingComplete, true);
    if(!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding, 
                child: Text("Skip", 
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                ),
              ),
            ),
            ),
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page){
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                           _pages[index].icon,
                        size: 150,
                        color:Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 48,),
                        Text(
                          _pages[index].title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24,),
                        Text(
                          _pages[index].description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                    _pages.length,
                    (index) => buildDot(index, context),
                    ),
                  ),

                  // Next/Get started button
                  ElevatedButton(
                    onPressed: (){
                      if(_currentPage == _pages.length - 1){
                        _completeOnboarding();
                      }else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120,50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ), 
                  child: Text(_currentPage == _pages.length -1 ? "Get Started" : "Next"),
                  ),
                ],
              ),
              ),
          ],
        ),
      ),
    );
  }
  Widget buildDot(int index, BuildContext context){
    return Container(
      height: 10,
      width: _currentPage == index? 24: 10,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColor,
      ),
    );
  }
}
class OnboardingData{
  final String title;
  final String description;
  final IconData icon;
  OnboardingData({required this.title, required this.description, required this.icon});
}