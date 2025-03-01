import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note_category.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/settings.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService extends ChangeNotifier{
  static late Isar isar;

  // List of notes
  final List<Note> currentNotes = [];

  // List of note categories
  final List<NoteCategory> noteCategories = [];

  // Settings
  Settings? _settings;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([SettingsSchema, NoteCategorySchema, NoteSchema], directory: dir.path);
  }
  
  // Create Default Settings
  Future<Settings> createDefaultSettings() async {
    Settings defaultSettings = Settings()
      ..id = 1
      ..isDarkModeEnabled = true;
    await isar.writeTxn(() async {
      await isar.settings.put(defaultSettings);
    });
    _settings = defaultSettings;
    return defaultSettings;
  }

  // Fetch settings
  Future<Settings> getSettings() async {
    if (_settings != null) {
      return _settings!;
    }

    final settings = await isar.settings.get(1);

    if (settings == null) {
      return createDefaultSettings();
    }
    else {
      _settings = settings;
      return settings;
    }
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
      await saveSettings(_settings!);
    }
    notifyListeners();
  }

  // Create Default Note Category
  Future<void> createDefaultNoteCategory() async {
    NoteCategory defaultNoteCategory = NoteCategory()
        ..id = Isar.autoIncrement
        ..name = "Notes";
      await isar.writeTxn(() async {
        await isar.noteCategorys.put(defaultNoteCategory);
      });
  }

  // Create Note Category
  Future<void> addNoteCategory(String noteCategoryName) async {
    // Create note object from user text
    final newNoteCategory = NoteCategory()..name = noteCategoryName;

    // Save to DB
    await isar.writeTxn(() => isar.noteCategorys.put(newNoteCategory));

    // Read from db
    fetchNoteCategories();
  }

  // Read Note Category
  Future<void> fetchNoteCategories() async {
    List<NoteCategory> fetchedNoteCategories = await isar.noteCategorys.where().findAll();

    if (fetchedNoteCategories.isEmpty) {
      await createDefaultNoteCategory();
      fetchedNoteCategories = await isar.noteCategorys.where().findAll();
    }

    noteCategories.clear();
    noteCategories.addAll(fetchedNoteCategories);

    notifyListeners();
  }

  // Called in main.dart to get categories before start. Could be changed?
  Future<List<NoteCategory>> getNoteCategories() async {
    List<NoteCategory> fetchedNoteCategories = await isar.noteCategorys.where().findAll();
    if (fetchedNoteCategories.isEmpty) {
      await createDefaultNoteCategory();
    }
    return await isar.noteCategorys.where().findAll();
  }
  
  // Update Note Category
  Future<void> updateNoteCategory(int id, String newName) async {
    final existingNoteCategory = await isar.noteCategorys.get(id);
    if (existingNoteCategory != null) {
      existingNoteCategory.name = newName;
      await isar.writeTxn(() => isar.noteCategorys.put(existingNoteCategory));
      await fetchNoteCategories();
    }
  }

  // Delete Note Category
  Future<bool> deleteNoteCategory(int id) async {
    // Check if it's the last category
    final totalCategories = await isar.noteCategorys.count();
    if (totalCategories <= 1) {
      // If it's the last category, do not delete and return false
      return false;
    }

    await isar.writeTxn(() async {
      // Delete all notes with the given noteCategoryId (stored as a string)
      await isar.notes.filter().noteCategoryIdEqualTo(id.toString()).deleteAll();
      // Delete the note category itself
      await isar.noteCategorys.delete(id);
    });
    await fetchNoteCategories();
    return true;
  }

  // Create Note
  Future<void> addNote(String textFromuser, Id noteCategoryId) async {
    // Create note object from user text
    final newNote = Note()
      ..text = textFromuser
      ..noteCategoryId = noteCategoryId.toString();

    // Save to DB
    await isar.writeTxn(() => isar.notes.put(newNote));

    // Read from db
    fetchNotes();
  }

  // Read Note
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  // Update Note
  Future<void> updateNoteText(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // Delete Note
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}