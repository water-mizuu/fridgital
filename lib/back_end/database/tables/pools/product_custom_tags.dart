import "package:flutter/foundation.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/database/tables/values/custom_tags.dart";
import "package:fridgital/back_end/database/tables/values/product.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";

/// This is just a "pointer" class or a class that holds references to values.
final class ProductCustomTagsTable extends DatabaseTable {
  const ProductCustomTagsTable._();

  static const ProductCustomTagsTable instance = ProductCustomTagsTable._();

  @override
  String get tableName => "productCustomTags";

  @override
  String get tableCreationStatement => """
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        productId INTEGER,
        tagId INTEGER,

        FOREIGN KEY (productId) REFERENCES ${ProductTable.instance.tableName} (id),
        FOREIGN KEY (tagId) REFERENCES ${CustomTagsTable.instance.tableName} (id)
      )
      """;

  Future<void> register({required int productId, required int tagId}) async {
    await ensureInitialized();
    await database.insert(tableName, {"productId": productId, "tagId": tagId});
  }

  Future<List<CustomTag>> fetchCustomTags({required int productId}) async {
    await ensureInitialized();
    var rows = await database.query(tableName, where: "productId = ?", whereArgs: [productId]);

    var futures = <Future<CustomTag>>[];
    for (var row in rows) {
      if (row case {"id": int _, "productId": int _, "tagId": int tagId}) {
        futures.add(CustomTagsTable.instance.fetchTagWithId(tagId));
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
    await database
        .delete(tableName, where: "productId = ? AND tagId = ?", whereArgs: [productId, tagId]);
  }
}
