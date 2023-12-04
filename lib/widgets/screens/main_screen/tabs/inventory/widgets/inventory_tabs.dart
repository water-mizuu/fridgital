import "dart:async";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers.dart/product_data.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/main.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/hooks.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_tab_location.dart";
import "package:provider/provider.dart";

class InventoryTabs extends HookWidget {
  const InventoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    var tabController = useTabController(
      initialLength: 3,
      initialIndex: sharedPreferences.getInt(SharedPreferencesKeys.inventoryLocation) ?? 0,
    );
    var debounce = useRef(null as Timer?);
    var focusNode = useFocusNodeWithAutoFocus();

    useEffect(
      () {
        void listener() {
          if (tabController.indexIsChanging) {
            return;
          }

          if (kDebugMode) {
            print("Tab changed to ${tabController.index}");
          }

          var index = tabController.index;

          debounce
            ..value?.cancel()
            ..value = Timer(200.ms, () async {
              if (kDebugMode) {
                print("Saved tab as $index");
              }
              ChangeWorkingStorageLocationNotification(StorageLocation.values[index]).dispatch(context);
              await sharedPreferences.setInt(SharedPreferencesKeys.inventoryLocation, index);
            });
        }

        tabController.addListener(listener);
        return () {
          tabController.removeListener(listener);
        };
      },
      [tabController, debounce],
    );

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (!kDebugMode) {
          return;
        }

        switch (event) {
          case KeyDownEvent(logicalKey: LogicalKeyboardKey(keyId: >= 0x31 && <= 0x39 && var id)):
            tabController.animateTo(id - 0x31);
        }
      },
      child: Column(
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
                              var tagCount = Random().nextInt(addableTags.length + 1);
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
      ),
    );
  }
}
