import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/settings.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService extends ChangeNotifier{
  static late Isar isar;

  // List of notes
  final List<Note> currentNotes = [];

  // Settings
  Settings? _settings;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([SettingsSchema, NoteSchema], directory: dir.path);
  }
  

  // Fetch settings
  Future<Settings> getSettings() async {
    if (_settings != null) {
      return _settings!;
    }

    final settings = await isar.settings.get(1);

    if (settings == null) {
      Settings defaultSettings = Settings()
        ..id = 1
        ..isDarkModeEnabled = true;
      await isar.writeTxn(() async {
        await isar.settings.put(defaultSettings);
      });
      _settings = defaultSettings;
      return defaultSettings;
    }

    _settings = settings;
    return settings;
  }

  // Save settings
  Future<void> saveSettings(Settings settings) async {
    await isar.writeTxn(() async {
      await isar.settings.put(settings);
    });

    _settings = settings;
    notifyListeners();
  }

  // Getter for dark mode status
  bool get isDarkModeEnabled => _settings?.isDarkModeEnabled ?? true;

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_settings != null) {
      _settings!.isDarkModeEnabled = !_settings!.isDarkModeEnabled;
      await saveSettings(_settings!);  // Save the updated setting
    }
    notifyListeners();
  }

  // Create
  Future<void> addNote(String textFromuser) async {
    // Create note object from user text
    final newNote = Note()..text = textFromuser;

    // Save to DB
    await isar.writeTxn(() => isar.notes.put(newNote));

    // Read from db
    fetchNotes();
  }

  // Read
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  // Update
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // Delete
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}