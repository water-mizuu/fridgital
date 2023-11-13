import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/widgets/inherited_widgets/inherited_tag_data.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final TagData tagData = TagData([
    BuiltInTag.essential,
  ]);

  @override
  void dispose() {
    tagData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTagData(
      tagData: tagData,
      child: const BasicScreenWidget(
        child: MouseSingleChildScrollView(
          child: Column(
            children: [
              InventoryTitle(),
              SizedBox(height: 16.0),
              TagsView(),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(32.0),
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
