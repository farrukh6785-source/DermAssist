import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermassist_fyp/constants.dart';

class ThemeProvider with ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences _prefs;
  ThemeProvider(this._prefs){
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void _loadThemeFromPrefs(){
    final String? savedTheme = _prefs.getString(AppConstants.prefsThemeMode);
    if (savedTheme != null){
      if(savedTheme == 'light'){
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark'){
        _themeMode = ThemeMode.dark;
      }
    }
    notifyListeners();
  }
  Future <void> setThemeMode(ThemeMode mode) async{
    _themeMode = mode;
    notifyListeners();
    
    String themeString = 'system';
    if(mode == ThemeMode.light) themeString = 'light';
    if(mode == ThemeMode.dark) themeString = 'dark';

    await _prefs.setString(AppConstants.prefsThemeMode, themeString);
  }
  Future<void> toogleTheme() async{
    if(_themeMode == ThemeMode.light){
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}