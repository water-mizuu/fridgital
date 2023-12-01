import "dart:typed_data";

import "package:flutter/material.dart";
import "package:fridgital/back_end/database/tables/values/product.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/immutable_list.dart";

enum StorageLocation { freezer, refrigerator, pantry }

class ProductData extends ChangeNotifier {
  ProductData(this._products);
  ProductData.empty() : _products = [];

  static Future<ProductData> fromDatabase() async {
    var products = await ProductTable.instance.fetchProducts();

    return ProductData(products);
  }

  final List<Product> _products;

  @pragma("vm:prefer-inline")
  ImmutableList<Product> get products => ImmutableList.copyFrom(_products);

  Future<void> addProduct({
    required String name,
    required DateTime addedDate,
    required List<Tag> tags,
    required StorageLocation storageLocation,
    required String storageUnits,
    required Uint8List? image,
    required DateTime? expiryDate,
    required String notes,
  }) async {
    var product = await ProductTable.instance.addProduct(
      name: name,
      addedDate: addedDate,
      tags: tags,
      storageLocation: storageLocation,
      storageUnits: storageUnits,
      expiryDate: expiryDate,
      image: image,
      notes: notes,
    );

    _products.add(product);
    notifyListeners();
  }

  Future<void> removeProduct({required int id}) async {
    if (_products.any((product) => product.id == id)) {
      await ProductTable.instance.removeProduct(id);
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    }
  }
}

class Product extends ChangeNotifier {
  Product({
    required this.id,
    required String name,
    required DateTime addedDate,
    required List<Tag> tags,
    required StorageLocation storageLocation,
    required String storageUnits,
    Uint8List? image,
    DateTime? expiryDate,
    String notes = "",
  })  : _name = name,
        _addedDate = addedDate,
        _image = image,
        _tags = tags,
        _storageLocation = storageLocation,
        _storageUnits = storageUnits,
        _expiryDate = expiryDate,
        _notes = notes;

  final int id;

  String _name;
  String get name => _name;
  set name(String name) {
    if (_name != name) {
      _name = name;
      notifyListeners();
    }
  }

  Uint8List? _image;
  Uint8List? get imageUrl => _image;
  set imageUrl(Uint8List? imageUrl) {
    if (_image != imageUrl) {
      _image = imageUrl;
      notifyListeners();
    }
  }

  DateTime _addedDate;
  DateTime get addedDate => _addedDate;
  set addedDate(DateTime addedDate) {
    if (_addedDate != addedDate) {
      _addedDate = addedDate;
      notifyListeners();
    }
  }

  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  set expiryDate(DateTime? expiryDate) {
    if (_expiryDate != expiryDate) {
      _expiryDate = expiryDate;
      notifyListeners();
    }
  }

  StorageLocation _storageLocation;
  StorageLocation get storageLocation => _storageLocation;
  set storageLocation(StorageLocation storageLocation) {
    if (_storageLocation != storageLocation) {
      _storageLocation = storageLocation;
      notifyListeners();
    }
  }

  String _storageUnits;
  String get storageUnits => _storageUnits;
  set storageUnits(String storageUnits) {
    if (_storageUnits != storageUnits) {
      _storageUnits = storageUnits;
      notifyListeners();
    }
  }

  String _notes;
  String get notes => _notes;
  set notes(String notes) {
    if (_notes != notes) {
      _notes = notes;
      notifyListeners();
    }
  }

  final List<Tag> _tags;
  ImmutableList<Tag> get tags => ImmutableList<Tag>(_tags);

  void addTag(Tag tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }
}
