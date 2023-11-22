import "package:fridgital/main.dart";

abstract base class DatabaseTable {
  const DatabaseTable();

  String get name;

  Future<void> create();

  Future<void> drop() async {
    await database.execute("DROP TABLE IF EXISTS $name");
  }

  Future<void> ensureInitialized() async {
    var table = await database.query("sqlite_master", where: "name = ?", whereArgs: [name]);
    if (table.isEmpty) {
      await create();
    }
  }
}
