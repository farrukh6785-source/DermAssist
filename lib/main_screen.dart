import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/home_dashboard_screen.dart';
import 'package:dermassist_fyp/consultation_history_screen.dart';
import 'package:dermassist_fyp/user_profile_screen.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
 class _MainScreenState extends State<MainScreen>{
  int _currentIndex = 0;
  final List<Widget>_screens =[
    const HomeDashboardScreen(),
    const ConsultationHistoryScreen(),
    const UserProfileScreen(),
  ];
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          items: const[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: "Profile",
                ),
          ],
        ),
      ),
    );
  }
 }