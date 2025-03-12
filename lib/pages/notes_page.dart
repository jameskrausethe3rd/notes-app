import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class _NotesPageState extends State<NotesPage> {
  NoteCategory currentNoteCategory = NoteCategory();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  bool _isFabVisible = true;
  int _currentPage = 0;

  // Text controller
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentNoteCategory = widget.categories.first;

    // Fetch notes on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      readNotes();
    });

    // Add scroll listener
    _scrollController.addListener(_onScroll);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
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
    context.read<DatabaseService>().fetchNotes();
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
  void deleteNoteAsync(int id) async {
    final index = context.read<DatabaseService>().currentNotes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final removedNote = context.read<DatabaseService>().currentNotes.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(removedNote, animation),
        duration: const Duration(milliseconds: 300),
      );
      await context.read<DatabaseService>().deleteNote(id);
      if (mounted) {
        setState(() {
          // Trigger a rebuild to update the UI
        });
      }
    }
  }

  void toggleNoteHiddenStatusAsync(int id) async {
    final index = context.read<DatabaseService>().currentNotes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final note = context.read<DatabaseService>().currentNotes[index];
      note.isHidden = !note.isHidden;
      await context.read<DatabaseService>().updateNoteHiddenStatus(id, note.isHidden);
      if (mounted) {
        setState(() {
          // Trigger a rebuild to update the UI
        });
      }
    }
  }

  Widget _buildRemovedItem(Note note, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: 0.0,
        child: NoteTile(
          text: note.text,
          onEditPressed: () => updateNote(note),
          onDeletePressed: () => deleteNoteAsync(note.id),
          onHiddenPressed: () => toggleNoteHiddenStatusAsync(note.id),
        ),
      ),
    );
  }

  void onCategorySelected(NoteCategory category) {
    setState(() {
      currentNoteCategory = category;
      _pageController.jumpToPage(0); // Reset to the first page
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<DatabaseService>();

    // Current notes
    List<Note> currentNotes = database.currentNotes.where((note) => note.noteCategoryId == currentNoteCategory.id.toString() && !note.isHidden).toList();
    List<Note> hiddenNotes = database.currentNotes.where((note) => note.noteCategoryId == currentNoteCategory.id.toString() && note.isHidden).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              onPressed: createNote,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          : null,
      drawer: MyDrawer(
        onCategorySelected: onCategorySelected,
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          Provider.of<DatabaseService>(context, listen: false).fetchNoteCategories();
        }
      },
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildNotesList(currentNotes, currentNoteCategory.name),
                _buildNotesList(hiddenNotes, "Hidden"),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(0),
                  _buildPageIndicator(1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == pageIndex
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 16.0),
          child: InkWell(
            child: Text(
              title,
              style: GoogleFonts.dmSerifText(
                fontSize: 48,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              // Don't allow updating category name if the current page is the last in the pageview
              if (_currentPage == 1) {
                return;
              }

              updateCategory(currentNoteCategory);
            },
          ),
        ),

        // List of notes
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              // Get individual note
              final note = notes[index];

              // List tile UI
              return NoteTile(
                text: note.text,
                onEditPressed: () => updateNote(note),
                onDeletePressed: () => deleteNoteAsync(note.id),
                onHiddenPressed: () => toggleNoteHiddenStatusAsync(note.id),
              );
            },
          ),
        ),
      ],
    );
  }
}