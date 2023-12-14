import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_tabs.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_tags.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/inventory/widgets/inventory_title.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";

class Inventory extends HookWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
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
}
