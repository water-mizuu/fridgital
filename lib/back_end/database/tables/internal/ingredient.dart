import "dart:convert";

import "package:flutter/foundation.dart";
import "package:fridgital/back_end/database/tables/table.dart";
import "package:fridgital/shared/extensions/as_extension.dart";
import "package:fridgital/shared/extensions/list_extension.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/shared/utils.dart";
import "package:http/http.dart" as http;

/// This table will only be used for internal queries.
final class MealsDbIngredientTable extends DatabaseTable {
  const MealsDbIngredientTable._();
  static const MealsDbIngredientTable instance = MealsDbIngredientTable._();

  @override
  String get tableName => "mealsDbIngredients";

  @override
  String get tableCreationStatement => """
    CREATE TABLE $tableName (
      id STRING PRIMARY KEY,
      name STRING NOT NULL
    )
  """;

  @override
  Future<void> create() async {
    await super.create();

    /// We pull all the ingredients in the database.
    var ingredientsRaw = await http.get(Uri.parse("https://www.themealdb.com/api/json/v1/1/list.php?i=list"));
    var body = ingredientsRaw.body;

    var futures = <Future<void>>[];
    if (jsonDecode(body) case {"meals": List<Object?> values}) {
      for (var value in values) {
        if (value case {"idIngredient": String id, "strIngredient": String name}) {
          futures.add(database.insert(tableName, {"id": id, "name": name}));
        }
      }
    }

    await Future.wait(futures);
  }

  /// Returns the closest ingredient to the given name. If no ingredient is found, returns null.
  /// The search is done using the Levenshtein distance. The search is case-insensitive.
  Future<String?> closestIngredientToName(String searchName) async {
    await ensureInitialized();

    var search = await database.query(tableName, orderBy: "LENGTH(name) ASC");
    var target = searchName.toLowerCase();
    var processed = search //
        .map((row) => row["name"]!.as<String>().toLowerCase())
        .map((name) => (distance: levenshtein(name, target), name: name))
        .where((pair) => pair.distance < 6)
        .toList()
        .sorted((pairA, pairB) => pairA.distance - pairB.distance)
        .sublist(0, 8);

    if (kDebugMode) {
      print("After processing, the search is: $processed");
    }

    return processed.firstOrNull?.name;
  }
}
