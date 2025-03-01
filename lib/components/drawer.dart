import 'package:flutter/material.dart';
import 'package:notes_app/components/custom_alert_dialog.dart';
import 'package:notes_app/components/drawer_tile.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:notes_app/models/note_category.dart';
import 'package:notes_app/pages/settings_page.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  final Function(NoteCategory) onCategorySelected;

  const MyDrawer({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const DrawerHeader(child: Icon(Icons.edit)),
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Consumer<DatabaseService>(
              builder: (context, db, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: ExpansionTile(
                    title: const Text("Notes"),
                    leading: const Icon(Icons.home),
                    children: [
                      // List each note category with trailing 3 dots
                      ...db.noteCategories.map((category) {
                        TextEditingController controller = TextEditingController(text: category.name);
                        return DrawerTile(
                          leadingIcon: Icons.note,
                          title: category.name,
                          onTap: () {
                            onCategorySelected(category);
                            Navigator.pop(context); // Close drawer
                          },
                          controller: controller,
                          onEdit: (context, controller) async {
                            await editCategory(context, controller, db, category);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          onDelete: (context) async {
                            bool? confirmed = await showDialog(
                              context: context,
                              builder: (context) {
                                return deleteCategory(context);
                              },
                            );
                            if (confirmed == true && context.mounted) {
                              await deleteAndFetchFirstCategory(context, db, category);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      }),
                      // "Create New" tile at the bottom of the ExpansionTile
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text("Create New"),
                        onTap: () async {
                          final db = Provider.of<DatabaseService>(context, listen: false);
                          TextEditingController controller = TextEditingController();
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return createCategory(controller, context, db);
                            },
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          // Settings tile
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  CustomAlertDialog createCategory(TextEditingController controller, BuildContext context, DatabaseService db) {
    return CustomAlertDialog(
      title: "Create Category",
      labelText: "Enter category name",
      controller: controller,
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmit: () async {
        if (controller.text.isNotEmpty) {
          await createAndFetchNewCategory(db, controller);
        }
        if (context.mounted) {
          Navigator.pop(context); 
        }
      }
    );
  }

  AlertDialog deleteCategory(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure?"),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context, false); // Cancel
          },
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.pop(context, true); // Confirm
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 4),
              Text("Delete",
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> editCategory(BuildContext context, TextEditingController controller, DatabaseService db, NoteCategory category) async {
    await showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: "Edit Category",
          labelText: "Enter new category name",
          controller: controller,
          onCancel: () {
            Navigator.pop(context);
          },
          onSubmit: () async {
            if (controller.text.isNotEmpty) {
              await updateAndFetchCurrentCategory(db, category, controller);
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  /// Creates a new note category before fetching the categories from the database 
  /// and then selecting the new (last) note category.
  Future<void> createAndFetchNewCategory(DatabaseService db, TextEditingController controller) async {
    await db.addNoteCategory(controller.text);
    // Re-fetch categories to update the list with the newly added category.
    await db.fetchNoteCategories();
    // Retrieve the newly added category.
    final newCategory = db.noteCategories.last;
    onCategorySelected(newCategory);
  }

  /// Deletes a note category before fetching the categories from the database 
  /// and then selecting the first note category.
  Future<void> deleteAndFetchFirstCategory(BuildContext context, DatabaseService db, NoteCategory category) async {
    bool success = await db.deleteNoteCategory(category.id);
    if (!context.mounted) return;
    if (success) {
      // Re-fetch categories to update the list with the newly added category.
      await db.fetchNoteCategories();
      if (!context.mounted) return;
      // Retrieve the newly added category.
      final newCategory = db.noteCategories.first;
      onCategorySelected(newCategory);
    } else {
      // Show a toast message if deletion failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete the last category")),
      );
    }
  }

  /// Updates a note category before fetching the categories from the database 
  /// and then selecting the updated note category.
  Future<void> updateAndFetchCurrentCategory(DatabaseService db, NoteCategory category, TextEditingController controller) async {
    await db.updateNoteCategory(category.id, controller.text);
    await db.fetchNoteCategories();
    final updatedCategory = db.noteCategories.firstWhere(
      (cat) => cat.id == category.id,
      orElse: () => category);
    onCategorySelected(updatedCategory);
  }
}