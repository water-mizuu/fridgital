import "dart:convert";
import "dart:isolate";

import "package:flutter/foundation.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/back_end/database/tables/pools/product_built_in_tags.dart";
import "package:fridgital/back_end/database/tables/pools/product_custom_tags.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/back_end/database/tables/values/built_in_tags.dart";
import "package:fridgital/back_end/database/tables/values/custom_tags.dart";
import "package:fridgital/main.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

final class ProductTable extends DatabaseTable {
  const ProductTable._();

  static const ProductTable instance = ProductTable._();

  @override
  String get tableName => "product";

  @override
  String get tableCreationStatement => """
    CREATE TABLE $tableName (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,

      name TEXT NOT NULL,
      addedDate TEXT NOT NULL,
      storageLocation INTEGER NOT NULL,
      storageUnits TEXT NOT NULL,
      notes TEXT NOT NULL,
      quantity INT NOT NULL,

      expiryDate TEXT,
      image BLOB
    )
    """;

  Future<List<Product>> fetchProducts() async {
    await ensureInitialized();
    var rows = await database.query(tableName);
    var products = <Product>[];

    for (var row in rows) {
      if (row
          case {
            "id": int id,
            "name": String name,
            "addedDate": String addedDate,
            "storageLocation": int storageLocation,
            "storageUnits": String units,
            "notes": String notes,
            "quantity": int quantity,
            "expiryDate": String? expiryDate,
            "image": String? imageBase64,
          }) {
        var <List<Tag>>[custom, builtIn] = await Future.wait([
          ProductCustomTagsTable.instance.fetchCustomTags(productId: id),
          ProductBuiltInTagsTable.instance.fetchBuiltInTags(productId: id),
        ]);

        var product = Product(
          id: id,
          name: name,
          addedDate: DateTime.parse(addedDate),
          storageLocation: StorageLocation.values[storageLocation],
          storageUnits: units,
          tags: [...custom, ...builtIn],
          notes: notes,
          quantity: quantity,
          expiryDate: expiryDate != null ? DateTime.parse(expiryDate) : null,
          image: imageBase64 == null ? null : await Isolate.run(() => base64Decode(imageBase64)),
        );

        products.add(product);
      } else if (kDebugMode) {
        print("Failed to parse product with id ${row["id"]}. The row info is: \n $row");
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
    required int quantity,
    required Uint8List? image,
    required DateTime? expiryDate,
    required String notes,
  }) async {
    var id = await database.insert(
      tableName,
      {
        "name": name,
        "addedDate": addedDate.toIso8601String(),
        "storageLocation": storageLocation.index,
        "storageUnits": storageUnits,
        "notes": notes,
        "quantity": quantity,
        "expiryDate": expiryDate?.toIso8601String(),
        "image": await Isolate.run(() => image == null ? null : base64Encode(image)),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    /// Insert each tag to their respective tables.
    var ids = await Future.wait([
      for (var tag in tags)
        switch (tag) {
          CustomTag(:var name) => database.query(
              CustomTagsTable.instance.tableName,
              where: "name = ?",
              whereArgs: [name],
            ).then((rows) => (name, rows[0]["id"]! as int)),
          BuiltInTag(:var name) => database.query(
              BuiltInTagsTable.instance.tableName,
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
              productId: id,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
          BuiltInTag(:var name) => ProductBuiltInTagsTable.instance.register(
              productId: id,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
        },
    ]);

    if (kDebugMode) {
      print("Successfully added '$name' with id $id in location $storageLocation");
    }

    return Product(
      id: id,
      name: name,
      addedDate: addedDate,
      tags: tags,
      storageLocation: storageLocation,
      storageUnits: storageUnits,
      quantity: quantity,
      image: image,
      expiryDate: expiryDate,
      notes: notes,
    );
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required DateTime addedDate,
    required List<Tag> tags,
    required StorageLocation storageLocation,
    required String storageUnits,
    required int quantity,
    required Uint8List? image,
    required DateTime? expiryDate,
    required String notes,
  }) async {
    await Future.wait([
      database.update(
        tableName,
        {
          "name": name,
          "addedDate": addedDate.toIso8601String(),
          "storageLocation": storageLocation.index,
          "storageUnits": storageUnits,
          "notes": notes,
          "quantity": quantity,
          "expiryDate": expiryDate?.toIso8601String(),
          "image": await Isolate.run(() => image == null ? null : base64Encode(image)),
        },
        where: "id = ?",
        whereArgs: [id],
      ),
      ProductCustomTagsTable.instance.unregisterProduct(productId: id),
      ProductBuiltInTagsTable.instance.unregisterProduct(productId: id),
    ]);

    /// Insert each tag to their respective tables.
    var ids = await Future.wait([
      for (var tag in tags)
        switch (tag) {
          CustomTag(:var name) => database.query(
              CustomTagsTable.instance.tableName,
              where: "name = ?",
              whereArgs: [name],
            ).then((rows) => (name, rows[0]["id"]! as int)),
          BuiltInTag(:var name) => database.query(
              BuiltInTagsTable.instance.tableName,
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
              productId: id,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
          BuiltInTag(:var name) => ProductBuiltInTagsTable.instance.register(
              productId: id,
              tagId: ids.firstWhere((pair) => pair.$1 == name).$2,
            ),
        },
    ]);

    if (kDebugMode) {
      print("Successfully modified '$name' with id $id in location $storageLocation");
    }
  }

  Future<void> removeProduct({required int id}) async {
    await Future.wait([
      database.delete(tableName, where: "id = ?", whereArgs: [id]),
      ProductCustomTagsTable.instance.unregisterProduct(productId: id),
      ProductBuiltInTagsTable.instance.unregisterProduct(productId: id),
    ]);

    if (kDebugMode) {
      print("Removed product with id $id");
    }
  }
}
