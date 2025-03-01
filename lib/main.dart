import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:notes_app/models/note_category.dart';
import 'package:notes_app/theme/theme.dart';
import 'package:notes_app/theme/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models/note.dart';
import 'models/settings.dart';
import 'pages/notes_page.dart';

void main() async {
  // Init DB
  WidgetsFlutterBinding.ensureInitialized();
  // await DatabaseService.initialize();

  final databaseService = DatabaseService();
  final dir = await getApplicationDocumentsDirectory();
  DatabaseService.isar = await Isar.open([SettingsSchema, NoteCategorySchema, NoteSchema], directory: dir.path);

  // Fetch categories before running the app
  List<NoteCategory> categories = await databaseService.getNoteCategories();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(categories: categories),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<NoteCategory> categories;

  const MyApp({super.key, required this.categories});

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
        ? darkMode
        : lightMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesPage(categories: categories, currentCategory: categories.first),
      theme: themeData,
    );
  }
}
