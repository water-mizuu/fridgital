// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class Inventory extends HookWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => inventory();
}

class InventoryTitle extends HookWidget {
  const InventoryTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => inventoryTitle();
}

class InventoryTags extends HookWidget {
  const InventoryTags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => inventoryTags();
}

class InventoryTabs extends HookWidget {
  const InventoryTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => inventoryTabs();
}

class InventoryTabLocation extends HookWidget {
  const InventoryTabLocation({
    Key? key,
    required this.location,
  }) : super(key: key);

  final StorageLocation location;

  @override
  Widget build(BuildContext _context) =>
      inventoryTabLocation(location: location);
}

class InventoryProduct extends HookWidget {
  const InventoryProduct({
    Key? key,
    required this.product,
    required this.parentDelete,
  }) : super(key: key);

  final Product product;

  final Future<void> Function() parentDelete;

  @override
  Widget build(BuildContext _context) => inventoryProduct(
        product: product,
        parentDelete: parentDelete,
      );
}
