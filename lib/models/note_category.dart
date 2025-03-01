import 'package:isar/isar.dart';

// This line is needed to generate file
// Run: dart run build_runner build
part 'note_category.g.dart';

@Collection()
class NoteCategory {
  Id id = Isar.autoIncrement;
  late String name;
}
