import "dart:typed_data";

import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/back_end/database/tables/values/product.dart";
import "package:fridgital/shared/classes/immutable_list.dart";
import "package:fridgital/shared/enums.dart";

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
    required String notes,
    required int quantity,
    required Uint8List? image,
    required String? description,
    required DateTime? expiryDate,
  }) async {
    var product = await ProductTable.instance.addProduct(
      name: name,
      addedDate: addedDate,
      tags: tags,
      storageLocation: storageLocation,
      storageUnits: storageUnits,
      notes: notes,
      quantity: quantity,
      expiryDate: expiryDate,
      image: image,
      description: description,
    );

    _products.add(product);
    notifyListeners();
  }

  Future<void> removeProduct({required int id}) async {
    if (_products.any((product) => product.id == id)) {
      await ProductTable.instance.removeProduct(id: id);
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    }
  }

  Future<void> removeProductWithoutNotifying({required int id}) async {
    if (_products.any((product) => product.id == id)) {
      await ProductTable.instance.removeProduct(id: id);
      _products.removeWhere((product) => product.id == id);
    }
  }

  Future<void> updateProduct(void Function(Product) callback, {required int id}) async {
    var product = _products.firstWhere((product) => product.id == id);
    callback(product);

    /// This should have mutated [product].

    await ProductTable.instance.updateProduct(
      id: id,
      name: product.name,
      addedDate: product.addedDate,
      tags: product.tags.toList(),
      storageLocation: product.storageLocation,
      storageUnits: product.storageUnits,
      notes: product.notes,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
      image: product.imageBytes,
      description: product.description,
    );
    notifyListeners();
  }

  Future<void> renameProduct({required int id, required String name}) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.updateProduct(
      id: id,
      name: name,
      addedDate: product.addedDate,
      tags: product.tags.toList(),
      storageLocation: product.storageLocation,
      storageUnits: product.storageUnits,
      notes: product.notes,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
      image: product.imageBytes,
      description: product.description,
    );

    product.name = name;
    notifyListeners();
  }

  Future<void> updateProductComplete({
    required int id,
    required String name,
    required DateTime addedDate,
    required List<Tag> tags,
    required StorageLocation storageLocation,
    required String storageUnits,
    required String notes,
    required int quantity,
    required Uint8List? image,
    required String? description,
    required DateTime? expiryDate,
  }) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.updateProduct(
      id: id,
      name: name,
      addedDate: addedDate,
      tags: tags,
      storageLocation: storageLocation,
      storageUnits: storageUnits,
      notes: notes,
      quantity: quantity,
      expiryDate: expiryDate,
      image: image,
      description: description,
    );

    product
      ..name = name
      ..addedDate = addedDate
      ..overrideTags(tags)
      ..storageLocation = storageLocation
      ..storageUnits = storageUnits
      ..notes = notes
      ..quantity = quantity
      ..expiryDate = expiryDate
      ..imageBytes = image
      ..description = description;
    notifyListeners();
  }

  Future<void> addProductTag({required int id, required Tag tag}) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.addTag(id: id, tag: tag);

    product.addTag(tag);
    notifyListeners();
  }

  Future<void> removeProductTag({required int id, required Tag tag}) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.removeTag(id: id, tag: tag);

    product.removeTag(tag);
    notifyListeners();
  }

  Future<void> updateProductImage({required int id, required Uint8List? image}) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.updateProduct(
      id: id,
      name: product.name,
      addedDate: product.addedDate,
      tags: product.tags.toList(),
      storageLocation: product.storageLocation,
      storageUnits: product.storageUnits,
      notes: product.notes,
      quantity: product.quantity,
      expiryDate: product.expiryDate,
      image: image,
      description: product.description,
    );

    product.imageBytes = image;
    notifyListeners();
  }

  Future<void> incrementProductQuantity({required int id}) async {
    var product = _products.firstWhere((product) => product.id == id);

    await ProductTable.instance.updateProduct(
      id: id,
      name: product.name,
      addedDate: product.addedDate,
      tags: product.tags.toList(),
      storageLocation: product.storageLocation,
      storageUnits: product.storageUnits,
      notes: product.notes,
      quantity: product.quantity + 1,
      expiryDate: product.expiryDate,
      image: product.imageBytes,
      description: product.description,
    );

    product.quantity++;
    notifyListeners();
  }

  Future<void> decrementProductQuantity({required int id}) async {
    var product = _products.firstWhere((product) => product.id == id);

    if (product.quantity <= 0) {
      return;
    }

    await ProductTable.instance.updateProduct(
      id: id,
      name: product.name,
      addedDate: product.addedDate,
      tags: product.tags.toList(),
      storageLocation: product.storageLocation,
      storageUnits: product.storageUnits,
      notes: product.notes,
      quantity: product.quantity - 1,
      expiryDate: product.expiryDate,
      image: product.imageBytes,
      description: product.description,
    );

    product.quantity--;
    notifyListeners();
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
    required int quantity,
    required Uint8List? image,
    required String? description,
    required DateTime? expiryDate,
    required String notes,
  })  : _name = name,
        _addedDate = addedDate,
        _image = image,
        _description = description,
        _tags = tags,
        _storageLocation = storageLocation,
        _storageUnits = storageUnits,
        _quantity = quantity,
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
  Uint8List? get imageBytes => _image;
  set imageBytes(Uint8List? imageUrl) {
    if (_image != imageUrl) {
      _image = imageUrl;
      notifyListeners();
    }
  }

  String? _description;
  String? get description => _description;
  set description(String? description) {
    if (_description != description) {
      _description = description;
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

  int _quantity;
  int get quantity => _quantity;
  set quantity(int quantity) {
    if (_quantity != quantity) {
      _quantity = quantity;
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

  void removeTag(Tag tag) {
    if (_tags.remove(tag)) {
      notifyListeners();
    }
  }

  void addTag(Tag tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void overrideTags(List<Tag> tags) {
    _tags
      ..clear()
      ..addAll(tags);

    notifyListeners();
  }
}
