import "package:flutter/foundation.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";

final class CustomTagsTable extends DatabaseTable {
  const CustomTagsTable._();

  static const CustomTagsTable instance = CustomTagsTable._();
  static const String tableName = "addableTags";

  @override
  String get name => tableName;

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

  Future<CustomTag> fetchTagWithId(int id) async {
    await ensureInitialized();
    var rows = await database.query(name, where: "id = ?", whereArgs: [id]);
    assert(rows.length == 1, "Ids should be unique!");

    var row = rows.first;
    if (rows.first case {"id": int _, "name": String name, "color": int color}) {
      return CustomTag(name, TagColors.selectable[color]);
    } else if (kDebugMode) {
      print("Row was not matched! The data was: $row");
    }

    throw Exception("There was no tag with the id $id!");
  }

  Future<List<CustomTag>> fetchAddableCustomTags() async {
    await ensureInitialized();
    var rows = await database.query(name);
    var tags = <CustomTag>[];

    for (var row in rows) {
      if (row case {"id": _, "name": String name, "color": int color}) {
        tags.add(CustomTag(name, TagColors.selectable[color]));
      } else if (kDebugMode) {
        print("Row was not matched! The data was: $row");
      }
    }

    return tags;
  }

  Future<void> addAddableTag(CustomTag tag) async {
    await database.insert(name, {"name": tag.name, "color": TagColors.selectable.indexOf(tag.color)});
  }

  Future<void> removeAddableTag(CustomTag tag) async {
    await database.delete(name, where: "name = ?", whereArgs: [tag.name]);
  }

  Future<void> replaceAddableTag(CustomTag target, CustomTag tag) async {
    await database.update(
      name,
      {"name": tag.name, "color": TagColors.selectable.indexOf(tag.color)},
      where: "name = ?",
      whereArgs: [target.name],
    );
  }
}
