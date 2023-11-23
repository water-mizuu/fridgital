import "package:fridgital/main.dart";

abstract base class DatabaseTable {
  const DatabaseTable();

  String get tableName;

  Future<void> create();

  Future<void> drop() async {
    await database.execute("DROP TABLE IF EXISTS $tableName");
  }

  Future<void> ensureInitialized() async {
    var table = await database.query("sqlite_master", where: "name = ?", whereArgs: [tableName]);
    if (table.isEmpty) {
      await create();
    }
  }
}
