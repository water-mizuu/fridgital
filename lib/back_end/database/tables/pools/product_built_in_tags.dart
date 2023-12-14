import "package:flutter/foundation.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/database/tables/values/built_in_tags.dart";
import "package:fridgital/back_end/database/tables/values/product.dart";
import "package:fridgital/shared/globals.dart";

/// This is just a "pointer" class or a class that holds references to values.
final class ProductBuiltInTagsTable extends DatabaseTable {
  const ProductBuiltInTagsTable._();

  static const ProductBuiltInTagsTable instance = ProductBuiltInTagsTable._();

  @override
  String get tableName => "productBuiltTags";

  @override
  String get tableCreationStatement => """
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY,
      productId INTEGER,
      tagId INTEGER,

      FOREIGN KEY (productId) REFERENCES ${ProductTable.instance.tableName} (id),
      FOREIGN KEY (tagId) REFERENCES ${BuiltInTagsTable.instance.tableName} (id)
    )
    """;

  Future<void> register({required int productId, required int tagId}) async {
    await ensureInitialized();

    /// Check if the tag is already registered.
    if (await database.query(tableName, where: "productId = ? AND tagId = ?", whereArgs: [productId, tagId]) case []) {
      await database.insert(tableName, {"productId": productId, "tagId": tagId});
    }
  }

  Future<List<BuiltInTag>> fetchBuiltInTags({required int productId}) async {
    await ensureInitialized();
    var rows = await database.query(tableName, where: "productId = ?", whereArgs: [productId]);

    var futures = <Future<BuiltInTag>>[];
    for (var row in rows) {
      if (row case {"id": int _, "productId": int _, "tagId": int tagId}) {
        futures.add(BuiltInTagsTable.instance.fetchTagWithId(tagId));
      } else if (kDebugMode) {
        print("Row was not matched! The data was: $row");
      }
    }

    var tags = await Future.wait(futures);

    return tags;
  }

  Future<void> unregisterProduct({required int productId}) async {
    await ensureInitialized();
    await database.delete(tableName, where: "productId = ?", whereArgs: [productId]);
  }

  Future<void> removeTagFromProduct({required int productId, required int tagId}) async {
    await ensureInitialized();

    int rows = await database.delete(tableName, where: "productId = ? AND tagId = ?", whereArgs: [productId, tagId]);
    if (kDebugMode) {
      print("Removed $rows from $tableName, by removing tag with id $tagId from product $productId!");
    }
  }
}
