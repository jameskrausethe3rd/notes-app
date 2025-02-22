import 'package:isar/isar.dart';

// This line is needed to generate file
// Run: dart run build_runner build
part 'settings.g.dart';

@Collection()
class Settings {
  Id id = 1;
  late bool isDarkModeEnabled = false;
}
