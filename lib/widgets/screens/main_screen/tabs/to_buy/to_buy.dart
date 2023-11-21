import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/checkbox_tile.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class ToBuy extends StatelessWidget {
  const ToBuy({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasicScreenWidget(
      child: MouseSingleChildScrollView(
        child: Row(
          children: [
            ToBuyTitle(),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class ToBuyTitle extends StatelessWidget {
  const ToBuyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("To-Buy".toUpperCase(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Text("Your suggested grocery list.", style: theme.textTheme.displayLarge),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              height: 660,
              width: 360,
              decoration: const BoxDecoration(
                  color: FigmaColors.whiteAccent, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: CheckBox(
                itemNameToBuy: "hi",
                itemObtainStatus: false,
                onChanged: (p0) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
