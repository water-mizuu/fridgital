import "dart:async";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks/use_reference.dart";
import "package:fridgital/shared/hooks/use_tag_data_future.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:functional_widget_annotation/functional_widget_annotation.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

part "inventory.g.dart";

@hwidget
Widget inventory() {
  useAutomaticKeepAlive();

  // ignore: discarded_futures
  var tagDataFuture = useTagDataFuture();

  return BasicScreenWidget(
    child: FutureBuilder(
      future: tagDataFuture,
      builder: (_, snapshot) => switch (snapshot) {
        AsyncSnapshot(connectionState: ConnectionState.done, hasData: true, :var data!) => ChangeNotifierProvider.value(
            value: data,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InventoryTitle(),
                SizedBox(height: 16.0),
                InventoryTags(),
                SizedBox(height: 16.0),
                Expanded(child: InventoryTabs()),
                shrinkingNavigationOffset,
              ],
            ),
          ),
        AsyncSnapshot(connectionState: ConnectionState.done, hasError: true, :var error!) =>
          Center(child: Text(error.toString())),
        _ => const Center(child: CircularProgressIndicator()),
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
        Text("What's currently in your pantry.", style: theme.textTheme.displayLarge),
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
  var tabController = useTabController(initialLength: 3);
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
                          child: Text("Add a product to ${location.name}"),
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

    var renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    var size = renderBox?.size ?? Size.zero;
    heightAnimationReference.value = Tween<double>(begin: size.height, end: 0.0)
        .animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: animationController));

    /// Then, we start to shrink the [SizedBox] to zero.
    ///   We do this by calling forward on the animation controller.

    await animationController.forward();

    /// Then, we reset the animation controller, and set [heightAnimation] to null.

    animationController.reset();
    heightAnimationReference.value = null;

    /// Lastly, we un mark the GlobalKey as being deleted.
    ///   We do this by marking the GlobalKey as being deleted.
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

                        await context.read<ProductData>().removeProduct(id: product.id);
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
  var behindKey = useMemoized(() => GlobalKey());
  var isOptionsVisible = useState(false);
  var animationController = useAnimationController(duration: 150.ms);

  Future<void> toggleIsOptionsVisible() async {
    isOptionsVisible.value = !isOptionsVisible.value;

    if (isOptionsVisible.value) {
      await animationController.forward();
    } else {
      await animationController.reverse();
    }
  }

  return LayoutBuilder(
    builder: (context, constraints) => AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        var renderBox = behindKey.currentContext?.findRenderObject() as RenderBox?;
        var targetHeight = renderBox?.size.height ?? 0.0;
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
                    color: FigmaColors.pinkAccent,
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
                  child: Text(
                    "${product.name} - ${product.tags.map((v) => v.name).join(", ")}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
