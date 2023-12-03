import "dart:async";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/classes/immutable_list.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/find_box.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks/use_global_key.dart";
import "package:fridgital/shared/hooks/use_reference.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/helper/invisible.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:functional_widget_annotation/functional_widget_annotation.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

part "inventory.g.dart";

@hwidget
Widget inventory() {
  useAutomaticKeepAlive();

  return BasicScreenWidget(
    child: TagDataProvider(
      builder: (context, tagData) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InventoryTitle(),
            SizedBox(height: 16.0),
            InventoryTags(),
            SizedBox(height: 16.0),
            Expanded(child: InventoryTabs()),
            shrinkingNavigationOffset,
          ],
        );
      },
    ),
  );
}

@hwidget
Widget inventoryTitle() {
  var context = useContext();
  var theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.only(top: 32.0) + const EdgeInsets.symmetric(horizontal: 32.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Inventory".toUpperCase(), style: theme.textTheme.titleLarge),
        const SizedBox(height: 8.0),
        Text("What's currently stocked.", style: theme.textTheme.displayLarge),
      ],
    ),
  );
}

@hwidget
Widget inventoryTags() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 32.0),
    child: TagsView(),
  );
}

@hwidget
Widget inventoryTabs() {
  var context = useContext();
  var tabController = useTabController(
    initialLength: 3,
    initialIndex: sharedPreferences.getInt(SharedPreferencesKeys.inventoryLocation) ?? 0,
  );
  var debounce = useReference(null as Future<void>?);

  useEffect(() {
    void listener() {
      if (tabController.indexIsChanging) {
        return;
      }

      if (kDebugMode) {
        print("Tab changed to ${tabController.index}");
      }

      var index = tabController.index;
      late Future<void> debounced;
      unawaited(
        debounce.value = debounced = Future.delayed(200.ms, () async {
          /// If we are not the active debounce anymore, then do nothing.
          if (debounce.value != debounced || !context.mounted) {
            return;
          }

          ChangeWorkingStorageLocationNotification(StorageLocation.values[index]).dispatch(context);
          await sharedPreferences.setInt(SharedPreferencesKeys.inventoryLocation, index);
        }),
      );
    }

    tabController.addListener(listener);
    return () {
      tabController.removeListener(listener);
    };
  });

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      /// This is where the tabs can be selected.
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: FigmaColors.whiteAccent,
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: TabBar(
            controller: tabController,
            labelPadding: EdgeInsets.zero,
            labelStyle: const TextStyle(
              fontFamily: "Nunito",
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: "FREEZER"),
              Tab(text: "REFRIGERATOR"),
              Tab(text: "PANTRY"),
            ],
          ),
        ),
      ),

      /// This is where the tabs are.
      // [TabBarView] needs to be constrained.
      Expanded(
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) => n.depth <= 0,
          child: TabBarView(
            controller: tabController,
            children: [
              for (var location in StorageLocation.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0) + const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: InventoryTabLocation(location: location)),
                      TextButton(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("Add a random product to ${location.name}"),
                        ),
                        onPressed: () {
                          var addableTags = context.read<TagData>().addableTags;
                          var tagCount = Random().nextInt(addableTags.length);
                          var tags = (addableTags.toList()..shuffle()) //
                              .take(tagCount)
                              .toList();

                          RouteState.of(context).createDummyProduct(tags);
                        },
                      ),
                      TextButton(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("Add a product to ${location.name}"),
                        ),
                        onPressed: () {
                          RouteState.of(context).toggleCreatingNewProduct();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

@hwidget
Widget inventoryTabLocation({required StorageLocation location}) {
  useAutomaticKeepAlive();

  var context = useContext();
  var scrollController = useScrollController();
  var animationController = useAnimationController(duration: 380.ms);
  var heightAnimationReference = useReference(null as Animation<double>?);

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

    var size = key.renderBoxNullable?.size ?? Size.zero;
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

const double tileHeight = 128.0;

@hwidget
Widget inventoryProduct({required Product product, required Future<void> Function() parentDelete}) {
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
    child: LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          var targetHeight = behindKey.renderBoxNullable?.size.height ?? 0.0;
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
                  child: Container(
                    height: tileHeight,
                    padding: const EdgeInsets.all(12.0),
                    color: isOptionsVisible.value ? Colors.grey[400] : FigmaColors.whiteAccent,
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
  );
}

enum ProductTabsRender { computing, rendering }

@hwidget
Widget inventoryProductTags({required Product product}) {
  var isExtraShown = useState(false);
  var isComputing = useState(true);

  var extraCounterKey = useGlobalKey();
  var tagContainerKey = useGlobalKey();

  var renderedTags = useState(product.tags);
  var renderedTagKeyPairs = useMemoized(
    () => [for (var tag in renderedTags.value) (tag, GlobalKey())],
    [renderedTags.value],
  );
  var hiddenTags = useMemoized(
    () => product.tags.skip(renderedTags.value.length).toList(),
    [product.tags, renderedTags.value],
  );

  useEffect(() {
    /// We compute for the overflow.

    if (renderedTags.value.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var containerSize = tagContainerKey.renderBoxNullable?.size ?? Size.zero;
      var productsThatCanBeFitted = <Tag>[];

      var accumulativeWidth = switch (extraCounterKey.renderBoxNullable?.size.width) {
        var width? => width + 2.0,
        null => 0.0,
      };

      for (var (index, (tag, key)) in renderedTagKeyPairs.indexed) {
        var size = key.renderBoxNullable?.size ?? Size.zero;
        var addedWidth = 2.0 + size.width;

        if (size == Size.zero || accumulativeWidth + addedWidth >= containerSize.width) {
          break;
        }

        productsThatCanBeFitted.add(tag);
        accumulativeWidth += size.width;
        accumulativeWidth += index > 0 ? 2.0 : 0.0; // Account for the spacing between the tags.
      }

      /// Since it overflows, we need to do some extra work.
      isExtraShown.value = productsThatCanBeFitted.length < product.tags.length;
      renderedTags.value = ImmutableList.copyFrom([for (var tag in productsThatCanBeFitted) tag]);
      isComputing.value = false;
    });
  });

  return Stack(
    alignment: Alignment.topLeft,
    children: [
      SizedBox(
        height: 24.0,
        child: OverflowBox(
          key: tagContainerKey,
          child: Align(
            alignment: Alignment.topLeft,
            child: Opacity(
              opacity: isComputing.value ? 0.0 : 1.0,
              child: Wrap(
                clipBehavior: Clip.hardEdge,
                spacing: 2.0,
                children: [
                  for (var (tag, key) in renderedTagKeyPairs)
                    SizedBox(
                      key: key,
                      height: 24.0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TagWidget(tag: tag, icon: null),
                      ),
                    ),

                  /// We only show this extra counter if the status is [ProductTabsRender.rendering].
                  if (isExtraShown.value)
                    SizedBox(
                      height: 24.0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TagWidget(
                          tag: CustomTag(-1, "+ ${hiddenTags.length}", TagColors.selectable[0]),
                          icon: null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (isComputing.value)
        Invisible(
          child: SizedBox(
            key: extraCounterKey,
            height: 24.0,
            child: FittedBox(
              child: TagWidget(
                tag: CustomTag(-1, "+ 1", TagColors.selectable[0]),
                icon: null,
              ),
            ),
          ),
        ),
    ],
  );
}

@hwidget
Widget inventoryProductCounter({required Product product}) {
  var context = useContext();
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

@hwidget
Widget inventoryCounterButton({required IconData icon, required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ClickableWidget(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xff807171)),
    ),
  );
}
