import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers.dart/product_data.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/extensions/find_box.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_product.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class InventoryTabLocation extends HookWidget {
  const InventoryTabLocation({required this.location, super.key});

  final StorageLocation location;

  @override
  Widget build(BuildContext context) {
    useAutomaticKeepAlive();

    var context = useContext();
    var scrollController = useScrollController();
    var animationController = useAnimationController(duration: 380.ms);
    var heightAnimationReference = useRef(null as Animation<double>?);

    var activeTags = context.select((TagData data) => data.activeTags);
    var products = context.select((ProductData data) => data.products);

    var (productPairs, isBeingDeleted) = useMemoized(
      () {
        var shownProducts = products
            .where((product) => product.storageLocation == location)
            .where((product) => activeTags.isEmpty || activeTags.every(product.tags.contains));

        var productPairs = shownProducts.map((p) => (p, GlobalKey())).toList();
        var isBeingDeleted = Set<GlobalKey>.identity();

        return (productPairs, isBeingDeleted);
      },
      [activeTags, products],
    );

    Future<void> deleteItemAt(int index) async {
      var (_, key) = productPairs[index];

      /// First, we make the item disappear.
      ///   Update the state to rebuild the widget.
      ///  We do this by marking the GlobalKey as being deleted.
      isBeingDeleted.add(key);

      /// Then, We replace it with a [SizedBox] of the same size.
      ///   We do this by creating an animation. Get the size of the box.
      ///   Since we marked the GlobalKey as being deleted, then the [build]
      ///   method will handle the replacement for us.

      var size = key.renderBox?.size ?? Size.zero;
      heightAnimationReference.value = Tween<double>(begin: size.height, end: 0.0)
          .animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: animationController));

      /// Then, we start to shrink the [SizedBox] to zero.
      ///   We do this by calling forward on the animation controller.

      await animationController.forward();

      /// Then, we reset the animation controller, and set [heightAnimation] to null.

      animationController.reset();
      heightAnimationReference.value = null;

      /// Lastly, we un mark the GlobalKey as being deleted.
      ///   We do this by un marking the GlobalKey as being deleted.
      isBeingDeleted.remove(key);

      ///   We also remove the GlobalKey from the list.
      productPairs.removeAt(index);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: scrollController,
        child: MouseSingleChildScrollView(
          controller: scrollController,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Iteration
                for (var (index, (product, key)) in productPairs.indexed)
                  if (heightAnimationReference.value case var heightAnimation? when isBeingDeleted.contains(key))
                    SizedBox(height: heightAnimation.value)
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      key: key,
                      child: InventoryProduct(
                        product: product,
                        parentDelete: () async {
                          await deleteItemAt(index);
                          if (!context.mounted) {
                            return;
                          }

                          await context.read<ProductData>().removeProductWithoutNotifying(id: product.id);
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
