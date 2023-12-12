import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/find_box.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_product_counter.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_product_tags.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:provider/provider.dart";

class InventoryProduct extends HookWidget {
  const InventoryProduct({
    required this.product,
    required this.parentDelete,
    super.key,
  });

  static const double tileHeight = 128.0;

  final Product product;
  final Future<void> Function() parentDelete;

  @override
  Widget build(BuildContext context) {
    var behindKey = useGlobalKey();
    var isOptionsVisible = useState(false);
    var animationController = useAnimationController(duration: 150.ms);

    Future<void> toggleIsOptionsVisible() async {
      isOptionsVisible.value = !isOptionsVisible.value;

      await HapticFeedback.heavyImpact();
      if (isOptionsVisible.value) {
        await animationController.forward();
      } else {
        await animationController.reverse();
      }
    }

    return ChangeNotifierProvider.value(
      value: product,
      child: ClickableWidget(
        hitTestBehavior: HitTestBehavior.translucent,
        onTap: () {
          RouteState.of(context).workingProduct = product;
        },
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              var targetHeight = behindKey.renderBox?.size.height ?? 0.0;
              var progression = Curves.easeOut.transform(animationController.value);

              return SizedBox(
                height: tileHeight + progression * targetHeight,
                child: child,
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClickableWidget(
                      onTap: parentDelete,
                      child: Container(
                        key: behindKey,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          color: Color(0x4085100D),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          "REMOVE THIS PRODUCT",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Nunito",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: GestureDetector(
                    onLongPress: toggleIsOptionsVisible,
                    onSecondaryTap: toggleIsOptionsVisible,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AnimatedContainer(
                        height: tileHeight,
                        padding: const EdgeInsets.all(12.0),
                        color: isOptionsVisible.value ? Colors.grey[300] : FigmaColors.whiteAccent,
                        duration: 380.ms,
                        curve: Curves.fastEaseInToSlowEaseOut,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    product.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${DateTime.now().difference(product.addedDate).inDays} days",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff807171),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: InventoryProductTags(product: product)),
                                const SizedBox(width: 16.0),
                                InventoryProductCounter(product: product),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
