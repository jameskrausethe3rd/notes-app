import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/components/drawer.dart';
import 'package:notes_app/components/note_tile.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/note_database.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() =>
      _NotesPageState();
}

class _NotesPageState
    extends State<NotesPage> {
  // Text controller
  final textController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch notes on startup
    readNotes();
  }

  // Create a note
  void createNote() {
    // Clear controller
    textController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
      title: const Text(
        "Create Note",
      ),
      content: TextField(
        controller: textController,
        cursorColor: Theme.of(context).colorScheme.inversePrimary,
        decoration: InputDecoration(
          labelText: 'Enter note', // Optional: Add a label for clarity
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary), alignLabelWithHint: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary, // Underline color when focused
              width: 2.0,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary, // Underline color when not focused
              width: 2.0,
            ),
          ),
        ),
      ),
      actions: [
        // Create button
        MaterialButton(
          onPressed: () {
            // Add to DB
            context.read<DatabaseService>().addNote(textController.text);

            // Clear controller
            textController.clear();

            // Close dialog
            Navigator.pop(context);
          },
          child: const Text("Create"),
        ),
      ],
    ),
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
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Update Note",
            ),
            content: TextField(
              controller: textController,
              cursorColor: Theme.of(context).colorScheme.inversePrimary,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.inversePrimary, // Underline color when focused
                    width: 2.0,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary, // Underline color when not focused
                    width: 2.0,
                  ),
                ),
              ),
            ),
            actions: [
              // Update button
              MaterialButton(
                onPressed: () {
                  // Update note in DB
                  context
                      .read<
                        DatabaseService
                      >()
                      .updateNote(
                        note.id,
                        textController
                            .text,
                      );
                  // Clear controller
                  textController
                      .clear();

                  // Close dialog box
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  "Update",
                ),
              ),
            ],
          ),
    );
  }

  // Delete a note
  void deleteNote(int id) {
    context
        .read<DatabaseService>()
        .deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    // Note DB
    final database =
        context.watch<DatabaseService>();

    // Current notes
    List<Note> currentNotes =
        database.currentNotes;

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
      drawer: const MyDrawer(),
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
            child: Text(
              'Notes',
              style: GoogleFonts.dmSerifText(
                fontSize: 48,
                color:
                    Theme.of(context)
                        .colorScheme
                        .inversePrimary,
              ),
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
                final note =
                    currentNotes[index];

                // List tile UI
                return NoteTile(
                  text: note.text,
                  onEditPressed:
                      () => updateNote(
                        note,
                      ),
                  onDeletePressed:
                      () => deleteNote(
                        note.id,
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
