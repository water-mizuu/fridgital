import "package:flutter/material.dart";
import "package:fridgital/shared/classes/immutable_list.dart";

class RecipeData extends ChangeNotifier {
  RecipeData();
}

class Recipe extends ChangeNotifier {
  Recipe({
    required String name,
    required String description,
    required List<String> ingredients,
    required String directions,
  })  : _name = name,
        _description = description,
        _ingredients = ingredients,
        _directions = directions;

  String _name;
  String get name => _name;
  set name(String name) {
    if (name != _name) {
      _name = name;
      notifyListeners();
    }
  }

  String _description;
  String get description => _description;
  set description(String description) {
    if (description != _description) {
      _description = description;
      notifyListeners();
    }
  }

  List<String> _ingredients;
  ImmutableList<String> get ingredients => ImmutableList.copyFrom(_ingredients);

  String _directions;
  String get directions => _directions;
  set directions(String directions) {
    if (directions != _directions) {
      _directions = directions;
      notifyListeners();
    }
  }
}
