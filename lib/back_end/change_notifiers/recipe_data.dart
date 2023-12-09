import "package:flutter/material.dart";
import "package:fridgital/shared/classes/immutable_list.dart";

class RecipeData extends ChangeNotifier {
  RecipeData();
}

class Recipe extends ChangeNotifier {
  Recipe({
    required String name,
    required List<String> ingredients,
    required String directions,
    required String? imageUrl,
  })  : _name = name,
        _ingredients = ingredients,
        _directions = directions,
        _imageUrl = imageUrl;

  String _name;
  String get name => _name;
  set name(String name) {
    if (name != _name) {
      _name = name;
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

  String? _imageUrl;
  String? get imageUrl => _imageUrl;
  set imageUrl(String? imageUrl) {
    if (imageUrl != _imageUrl) {
      _imageUrl = imageUrl;
      notifyListeners();
    }
  }
}
