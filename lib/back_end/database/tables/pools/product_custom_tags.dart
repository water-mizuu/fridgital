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
  static const String tableName = "productCustomTags";

  @override
  String get name => tableName;

  @override
  Future<void> create() async {
    await database.execute(
      """
      CREATE TABLE $name (
        id INTEGER PRIMARY KEY,
        productId INTEGER,
        tagId INTEGER,

        FOREIGN KEY (productId) REFERENCES ${ProductTable.tableName} (id),
        FOREIGN KEY (tagId) REFERENCES ${CustomTagsTable.tableName} (id)
      )
      """,
    );
  }

  Future<void> register({required int productId, required int tagId}) async {
    await ensureInitialized();
    await database.insert(name, {"productId": productId, "tagId": tagId});
  }

  Future<Iterable<CustomTag>> fetchCustomTagsOfProduct({required int id}) async {
    await ensureInitialized();
    var rows = await database.query(name, where: "productId = ?", whereArgs: [id]);

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

  /// TODO(water-mizuu): Add the following:
  ///   - remove tag from specific product
  ///   - remove all tags from specific product
  ///   - remove a product.
}
