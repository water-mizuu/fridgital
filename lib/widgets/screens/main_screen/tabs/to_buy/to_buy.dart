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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToBuyTitle(),
          SizedBox(height: 16.0),
          Expanded(child: ToBuyBody()),

          /// Insets for the navbar.
          SizedBox(height: 64.0 + 16.0),
        ],
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
        ],
      ),
    );
  }
}

class ToBuyBody extends StatelessWidget {
  const ToBuyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: MouseSingleChildScrollView(
          child: ColoredBox(
            color: FigmaColors.whiteAccent,
            child: Column(
              children: [
                for (int i = 0; i < 50; ++i) ...[
                  CheckBox(
                    itemNameToBuy: "hi",
                    itemObtainStatus: false,
                    onChanged: (p0) {},
                  ),
                  CheckBox(
                    itemNameToBuy: "hi",
                    itemObtainStatus: true,
                    onChanged: (p0) {},
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
