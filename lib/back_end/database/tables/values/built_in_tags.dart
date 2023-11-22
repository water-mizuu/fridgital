import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";

final class BuiltInTagsTable extends DatabaseTable {
  const BuiltInTagsTable._();

  static const BuiltInTagsTable instance = BuiltInTagsTable._();
  static const String tableName = "builtInTags";

  @override
  String get name => tableName;

  @override
  Future<void> create() async {
    await database.execute(
      """
      CREATE TABLE $name (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,

        red INTEGER NOT NULL,
        green INTEGER NOT NULL,
        blue INTEGER NOT NULL
      )
      """,
    );

    await Future.wait([
      for (var BuiltInTag(:name, color: Color(:red, :green, :blue)) in BuiltInTag.values)
        database.insert(this.name, {"name": name, "red": red, "green": green, "blue": blue}),
    ]);
  }

  Future<BuiltInTag> fetchTagWithId(int id) async {
    await ensureInitialized();
    var rows = await database.query(name, where: "id = ?", whereArgs: [id]);
    assert(rows.length == 1, "Ids should be unique!");

    var row = rows.first;
    if (row case {"id": int _, "name": String name, "red": int red, "blue": int blue, "green": int green}) {
      return BuiltInTag(name, Color.fromARGB(255, red, green, blue));
    } else if (kDebugMode) {
      print("Row was not matched! The data was: $row");
    }

    throw Exception("There was no tag with the id $id!");
  }

  Future<List<BuiltInTag>> fetchAddableBuiltInTags() async {
    await ensureInitialized();
    var rows = await database.query(name);
    var tags = <BuiltInTag>[];

    for (var row in rows) {
      if (row case {"id": _, "name": String name, "red": int red, "blue": int blue, "green": int green}) {
        tags.add(BuiltInTag(name, Color.fromARGB(255, red, green, blue)));
      } else if (kDebugMode) {
        print("Row was not matched! The data was: $row");
      }
    }

    return tags;
  }
}
