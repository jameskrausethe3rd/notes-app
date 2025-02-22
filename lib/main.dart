import 'package:flutter/material.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:notes_app/theme/theme.dart';
import 'package:notes_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/notes_page.dart';

void main() async {
  // Init DB
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    context
      .read<DatabaseService>()
      .getSettings();

    // Access the settings from the SettingsProvider
    final isDarkModeEnabled = Provider.of<DatabaseService>(context).isDarkModeEnabled;

    // Choose the theme based on darkMode
    final ThemeData themeData = isDarkModeEnabled
        ? darkMode  // Use dark theme if darkMode is true
        : lightMode; // Use light theme if darkMode is false

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NotesPage(),
      theme: themeData,
    );
  }
}
