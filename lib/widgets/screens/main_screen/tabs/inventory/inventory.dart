import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/as_extension.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks/use_tag_data_future.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
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

class InventoryTitle extends StatelessWidget {
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

class InventoryTags extends StatelessWidget {
  const InventoryTags({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: TagsView(),
    );
  }
}

class InventoryTabs extends StatefulWidget {
  const InventoryTabs({super.key});

  @override
  State<InventoryTabs> createState() => _InventoryTabsState();
}

class _InventoryTabsState extends State<InventoryTabs> with TickerProviderStateMixin {
  late final TabController tabController;

  late Future<void>? debounce;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (tabController.indexIsChanging) {
          return;
        }

        if (kDebugMode) {
          print("Tab changed to ${tabController.index}");
        }

        var index = tabController.index;
        late Future<void> debounced;
        unawaited(
          debounce = debounced = Future.delayed(200.ms, () async {
            if (debounce != debounced) {
              return;
            }

            if (!context.mounted) {
              return;
            }

            ChangeWorkingStorageLocationNotification(StorageLocation.values[index]).dispatch(context);
            await sharedPreferences.setInt(SharedPreferencesKeys.inventoryLocation, index);
          }),
        );
      });
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          RouteState.of(context).toggleCreatingNewProduct();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class InventoryTabLocation extends StatelessWidget {
  const InventoryTabLocation({required this.location, super.key});

  final StorageLocation location;

  @override
  Widget build(BuildContext context) {
    var tagData = context.watch<TagData>();
    var productData = context.watch<ProductData>();

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: MouseSingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var product in productData.products.where((p) => p.storageLocation == location))
                if (tagData.activeTags.isEmpty || tagData.activeTags.any((tag) => product.tags.contains(tag)))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InventoryProduct(product: product),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryProduct extends StatefulWidget {
  const InventoryProduct({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  State<InventoryProduct> createState() => _InventoryProductState();
}

class _InventoryProductState extends State<InventoryProduct> with TickerProviderStateMixin {
  static const double tileHeight = 128.0;

  final GlobalKey behindKey = GlobalKey();

  late final ValueNotifier<bool> isOptionsVisible;
  late final AnimationController animationController;

  void toggleIsOptionsVisible() {
    setState(() {
      isOptionsVisible.value = !isOptionsVisible.value;
    });

    if (isOptionsVisible.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    isOptionsVisible = ValueNotifier<bool>(false);
    animationController = AnimationController(vsync: this, duration: 150.ms);
  }

  @override
  Widget build(BuildContext context) {
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
                child: Container(
                  key: behindKey,
                  padding: const EdgeInsets.all(12.0),
                  color: FigmaColors.pinkAccent,
                  child: const Text(
                    "DELETE",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
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
                      "${widget.product.name} - ${widget.product.tags}",
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
