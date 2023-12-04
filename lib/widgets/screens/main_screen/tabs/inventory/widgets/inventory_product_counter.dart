import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_counter_button.dart";
import "package:provider/provider.dart";

class InventoryProductCounter extends HookWidget {
  const InventoryProductCounter({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var quantity = context.select((Product product) => product.quantity);

    return Container(
      height: 36.0,
      decoration: BoxDecoration(
        color: const Color(0xffECDCDC),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          InventoryCounterButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () async {
              await context.read<ProductData>().decrementProductQuantity(id: product.id);
            },
          ),
          const VerticalDivider(width: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              child: Column(
                children: [
                  Text(
                    quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff807171)),
                  ),
                  Text(
                    product.storageUnits,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff807171)),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          InventoryCounterButton(
            icon: Icons.keyboard_arrow_up,
            onTap: () async {
              await context.read<ProductData>().incrementProductQuantity(id: product.id);
            },
          ),
        ],
      ),
    );
  }
}
