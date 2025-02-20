import 'package:flutter/material.dart';

// Light mode
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.pink.shade400,
    inversePrimary: Colors.grey.shade800,
  ),
);

// Dark mode
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.pink.shade400,
    inversePrimary: Colors.grey.shade300,
  ),
);
