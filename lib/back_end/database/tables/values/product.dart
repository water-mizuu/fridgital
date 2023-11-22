import "package:flutter/foundation.dart";
import "package:fridgital/back_end/database/tables/pools/product_built_in_tags.dart";
import "package:fridgital/back_end/database/tables/pools/product_custom_tags.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/database/tables/values/built_in_tags.dart";
import "package:fridgital/back_end/database/tables/values/custom_tags.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

final class ProductTable extends DatabaseTable {
  const ProductTable._();

  static const ProductTable instance = ProductTable._();
  static const String tableName = "product";

  @override
  String get name => tableName;

  @override
  Future<void> create() async {
    /// The image CAN be null.
    await database.execute(
      """
      CREATE TABLE $name (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,
        addedDate TEXT NOT NULL,
        storageLocation INTEGER NOT NULL,
        storageUnits TEXT NOT NULL,
        notes TEXT NOT NULL,

        expiryDate TEXT,
        imageUrl TEXT
      )
      """,
    );
  }

  Future<Iterable<Product>> fetchProducts() async {
    await ensureInitialized();
    var rows = await database.query(name);
    var products = <Product>[];

    for (var row in rows) {
      if (row
          case {
            "id": int id,
            "name": String name,
            "addedDate": String addedDate,
            "storageLocation": int storageLocation,
            "storageUnits": String units,
          }) {
        var [custom, builtIn] = await Future.wait([
          ProductCustomTagsTable.instance.fetchCustomTagsOfProduct(id: row["id"]! as int),
          ProductBuiltInTagsTable.instance.fetchBuiltInTags(productId: row["id"]! as int),
        ]);

        var product = Product(
          id: id,
          name: name,
          addedDate: DateTime.parse(addedDate),
          storageLocation: StorageLocation.values[storageLocation],
          storageUnits: units,
          tags: [...custom, ...builtIn],
        );

        products.add(product);
      }
    }

    return products;
  }

  Future<Product> addProduct({
    required String name,
    required DateTime addedDate,
    required List<Tag> tags,
    required StorageLocation storageLocation,
    required String storageUnits,
    String? imageUrl,
    DateTime? expiryDate,
    String notes = "",
  }) async {
    var productId = await database.insert(
      name,
      {
        "name": name,
        "addedDate": addedDate.toIso8601String(),
        "storageLocation": storageLocation.index,
        "storageUnits": storageUnits,
        "notes": notes,
        "expiryDate": expiryDate?.toIso8601String(),
        "imageUrl": imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    /// Insert each tag to their respective tables.
    var ids = await Future.wait([
      for (var tag in tags)
        switch (tag) {
          CustomTag(:var name) => database.query(
              CustomTagsTable.tableName,
              where: "name = ?",
              whereArgs: [name],
            ).then((rows) => (name, rows[0]["id"]! as int)),
          BuiltInTag(:var name) => database.query(
              BuiltInTagsTable.tableName,
              where: "name = ?",
              whereArgs: [name],
            ).then((rows) => (name, rows[0]["id"]! as int))
        },
    ]);

    /// Register each tag to their respective product.
    await Future.wait([
      for (var tag in tags)
        switch (tag) {
          CustomTag(:var name) => ProductCustomTagsTable.instance.register(
              productId: productId,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
          BuiltInTag(:var name) => ProductBuiltInTagsTable.instance.register(
              productId: productId,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
        },
    ]);

    if (kDebugMode) {
      print("Successfully added '$name' with id $productId");
    }

    return Product(
      id: productId,
      name: name,
      addedDate: addedDate,
      tags: tags,
      storageLocation: storageLocation,
      storageUnits: storageUnits,
    );
  }

  Future<void> removeProduct(Product product) async {}
}
