import "dart:async";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/as_extension.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks/use_reference.dart";
import "package:fridgital/shared/hooks/use_tag_data_future.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class Inventory extends HookWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
    useAutomaticKeepAlive();

    // ignore: discarded_futures
    var tagDataFuture = useTagDataFuture();

    return BasicScreenWidget(
      child: FutureBuilder(
        future: tagDataFuture,
        builder: (context, snapshot) => switch (snapshot) {
          AsyncSnapshot(connectionState: ConnectionState.done, hasData: true, :var data!) =>
            ChangeNotifierProvider.value(
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
}

class InventoryTitle extends HookWidget {
  const InventoryTitle({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class InventoryTags extends HookWidget {
  const InventoryTags({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: TagsView(),
    );
  }
}

class InventoryTabs extends HookWidget {
  const InventoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    var tabController = useTabController(initialLength: 3, vsync: useSingleTickerProvider());
    var debounce = useReference<Future<void>?>(null);

    useEffect(() {
      tabController.addListener(() {
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
      });
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
                        InventoryTabLocation(location: location),
                        TextButton(
                          child: Text("Add a product to ${location.name}"),
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
}

class InventoryTabLocation extends StatefulHookWidget {
  const InventoryTabLocation({required this.location, super.key});

  final StorageLocation location;

  @override
  State<InventoryTabLocation> createState() => _InventoryTabLocationState();
}

class _InventoryTabLocationState extends State<InventoryTabLocation> with TickerProviderStateMixin {
  late final ScrollController scrollController;
  late final AnimationController animationController;

  late final List<Product> products;
  late final List<GlobalKey> globalKeys;
  late final Map<GlobalKey, bool> isBeingDeleted;
  Animation<double>? heightAnimation;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    animationController = AnimationController(vsync: this, duration: 325.ms);

    products = [];
    globalKeys = [];
    isBeingDeleted = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// We compute the products to show here.
    ///
    /// ESSAY:
    /// Why here, and why not in [build]?
    ///
    /// Well the answer is, we need this to run every time our [watch] method gets updated.
    ///  Therefore, we can control whether or not this updates our UI.
    ///
    /// Basically, I don't like putting this in [build], so I put it here.
    var tags = context.watch<TagData>().activeTags;
    var shownProducts = context //
        .watch<ProductData>()
        .products
        .where((product) => product.storageLocation == widget.location)
        .where((product) => !tags.isNotEmpty || tags.every(product.tags.contains));

    products
      ..clear()
      ..addAll(shownProducts);

    globalKeys
      ..clear()
      ..addAll(shownProducts.map((product) => new GlobalKey()));

    isBeingDeleted
      ..clear()
      ..addAll(Map.fromIterable(globalKeys, value: (_) => false));
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();

    super.dispose();
  }

  Future<void> deleteItemAt(int index) async {
    var globalKey = globalKeys[index];
    var size = globalKey.currentContext?.findRenderObject()?.as<RenderBox>().size ?? Size.zero;

    /// First, we make the item disappear.
    ///   Update the state to rebuild the widget.
    setState(() {
      ///  e do this by marking the GlobalKey as being deleted.
      isBeingDeleted[globalKey] = true;
    });

    /// Then, We replace it with a [SizedBox] of the same size.
    ///   We do this by creating an animation. Get the size of the box.
    ///   Since we marked the GlobalKey as being deleted, then the [build]
    ///   method will handle the replacement for us.

    heightAnimation = Tween<double>(begin: size.height, end: 0.0)
        .animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: animationController));

    /// Then, we link the height of the [SizedBox] to the animation.
    ///  We do this by using an [AnimatedBuilder] in the build method.

    /// Then, we start to shrink the [SizedBox] to zero.
    ///   We do this by calling forward on the animation controller.

    await animationController.forward();

    /// Then, we reset the animation controller, and set [heightAnimation] to null.

    animationController.reset();
    heightAnimation = null;

    /// Lastly, we un mark the GlobalKey as being deleted.
    setState(() {
      /// We do this by marking the GlobalKey as being deleted.
      isBeingDeleted[globalKey] = false;

      /// We also remove the GlobalKey from the list.
      products.removeAt(index);
      globalKeys.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: MouseSingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Iteration
                for (var (index, product) in products.indexed.take(globalKeys.length))
                  if (isBeingDeleted[globalKeys[index]] case true)
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) => SizedBox(height: heightAnimation!.value),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      key: globalKeys[index],
                      child: InventoryProduct(
                        index: index,
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
}

class InventoryProduct extends HookWidget {
  const InventoryProduct({required this.index, required this.product, required this.parentDelete, super.key});

  static const double tileHeight = 128.0;

  final int index;
  final Product product;
  final Future<void> Function() parentDelete;

  @override
  Widget build(BuildContext context) {
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
          var height = behindKey.currentContext?.findRenderObject()?.as<RenderBox>().size.height ?? 0.0;
          var curve = Curves.easeOut.transform(animationController.value);

          return SizedBox(
            height: tileHeight + curve * height,
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
}
