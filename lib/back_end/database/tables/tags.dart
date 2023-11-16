import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";

final class CustomTagsTable extends DatabaseTable {
  CustomTagsTable._();

  @override
  String get name => "addableTags";

  static CustomTagsTable instance = CustomTagsTable._();

  @override
  Future<void> create() async {
    await database.execute(
      """
      CREATE TABLE $name (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
      )
      """,
    );
  }

  Future<Iterable<Tag>> fetchAddableTags() async {
    await ensureInitialized();
    var rows = await database.query(name);

    return () sync* {
      for (var row in rows) {
        if (row case {"id": int _, "name": String name, "color": int color}) {
          yield CustomTag(name, TagColors.selectable[color]);
        }
      }
    }();
  }

  Future<void> addAddableTag(CustomTag tag) async {
    await database.insert(name, {"name": tag.name, "color": TagColors.selectable.indexOf(tag.color)});
  }

  Future<void> removeAddableTag(CustomTag tag) async {
    await database.delete(name, where: "name = ?", whereArgs: [tag.name]);
  }
}
