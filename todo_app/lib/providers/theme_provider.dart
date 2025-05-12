import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme is light

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) { // isOn will represent if dark mode should be on
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // // Alternative toggle if you just want to switch between light and dark
  // void simpleToggleTheme() {
  //   _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  //   notifyListeners();
  // }
} 