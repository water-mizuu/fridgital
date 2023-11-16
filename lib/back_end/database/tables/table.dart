import "package:fridgital/main.dart";

abstract base class DatabaseTable {
  String get name;

  Future<void> create();

  Future<void> ensureInitialized() async {
    var table = await database.query("sqlite_master", where: "name = ?", whereArgs: [name]);
    if (table.isEmpty) {
      await create();
    }
  }
}
