import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/components/custom_alert_dialog.dart';
import 'package:notes_app/components/drawer.dart';
import 'package:notes_app/components/note_tile.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/note_category.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  final List<NoteCategory> categories;
  final NoteCategory currentCategory;

  const NotesPage({super.key, required this.categories, required this.currentCategory});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState
  extends State<NotesPage> {

  NoteCategory currentNoteCategory = NoteCategory();

  // Text controller
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentNoteCategory = widget.categories.first;

    // Fetch notes on startup
    readNotes();
  }

  // Update a category
  void updateCategory(NoteCategory noteCategory) {
    // Pre-fill the current note text
    textController.text = noteCategory.name;
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: "Edit Category",
          labelText: "Enter a new category name",
          controller: textController,
          onCancel: () {
            Navigator.pop(context);
          },
          onSubmit: () async {
            // Update note category in DB
            await context.read<DatabaseService>().updateNoteCategory(
              noteCategory.id,
              textController.text,
            );
            // Clear controller
            textController.clear();

            // Close dialog box
            if (context.mounted) {
              Navigator.pop(context);
              final updatedCategory = context.read<DatabaseService>().noteCategories.firstWhere(
                (cat) => cat.id == noteCategory.id,
                orElse: () => noteCategory
              );
              
              setState(() {
                currentNoteCategory = updatedCategory;
              });
            }
          }
        );
      }
    );
  }

  // Create a note
  void createNote() {
    // Clear controller
    textController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: "Create Note",
          labelText: "Enter note",
          controller: textController,
          onCancel: () {
            Navigator.pop(context);
          },
          onSubmit: () async {
            // Add to DB
            context.read<DatabaseService>().addNote(
              textController.text,
              currentNoteCategory.id,
            );

            // Clear controller
            textController.clear();

            // Close dialog box
            Navigator.pop(context);
          },
        );
      }
    );
  }

  // Read a note
  void readNotes() {
    context
        .read<DatabaseService>()
        .fetchNotes();
  }

  // Update a note
  void updateNote(Note note) {
    // Pre-fill the current note text
    textController.text = note.text;
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: "Update Note",
          labelText: "Enter note",
          controller: textController,
          onCancel: () {
            Navigator.pop(context);
          },
          onSubmit: () async {
            // Update note in DB
            context.read<DatabaseService>().updateNoteText(
              note.id,
              textController.text,
            );
            // Clear controller
            textController.clear();

            // Close dialog box
            Navigator.pop(context);
          },
        );
      }
    );
  }

  // Delete a note
  void deleteNote(int id) {
    context.read<DatabaseService>().deleteNote(id);
  }

  void onCategorySelected(NoteCategory category) {
    setState(() {
      currentNoteCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
  final database = context.watch<DatabaseService>();

  // Current notes
  List<Note> currentNotes = database.currentNotes.where((note) => note.noteCategoryId == currentNoteCategory.id.toString()).toList();

  return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        Colors.transparent,
      ),
      backgroundColor:
        Theme.of(
          context,
        ).colorScheme.surface,
      floatingActionButton:
        FloatingActionButton(
          onPressed: createNote,
          backgroundColor:
              Theme.of(
                context,
              ).colorScheme.secondary,
          child: Icon(
            Icons.add,
            color:
                Theme.of(context)
                    .colorScheme
                    .inversePrimary,
          ),
        ),
      drawer: MyDrawer(
        onCategorySelected: onCategorySelected),
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            Provider.of<DatabaseService>(context, listen: false).fetchNoteCategories();
          }
        },
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // Heading
          Padding(
            padding:
                const EdgeInsets.only(
                  left: 25.0,
                ),
            child: InkWell(
              child: Text(
                currentNoteCategory.name,
                style: GoogleFonts.dmSerifText(
                  fontSize: 48,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .inversePrimary,
                ),
              ),
              onTap: () => updateCategory(currentNoteCategory),
            ),
          ),
      
          // List of notes
          Expanded(
            child: ListView.builder(
              itemCount:
                  currentNotes.length,
              itemBuilder: (
                context,
                index,
              ) {
                // Get individual note
                final note = currentNotes[index];
      
                // List tile UI
                return NoteTile(
                  text: note.text,
                  onEditPressed: () => updateNote(note),
                  onDeletePressed: () => deleteNote(note.id),
                );
              },
            ),
          ),
        ],
      )       
    );
  }
}
