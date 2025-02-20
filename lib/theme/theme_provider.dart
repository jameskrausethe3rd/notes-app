import 'package:flutter/material.dart';
import 'package:notes_app/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  // Start as light mode
  ThemeData _themeData = lightMode;

  // Getter to access the theme from other parts of the app
  ThemeData get themeData => _themeData;

  // Getter to see if we are in dark mode or not
  bool get isDarkMode => _themeData == darkMode;

  // Setter method to set the new theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // Toggle the theme between light mode and dark mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
