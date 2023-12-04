import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class InventoryTitle extends HookWidget {
  const InventoryTitle({super.key});

  @override
  Widget build(BuildContext context) {
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
}
