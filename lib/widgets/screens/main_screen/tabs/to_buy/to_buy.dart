import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/checkbox_tile.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class ToBuy extends StatefulWidget {
  const ToBuy({super.key});

  @override
  State<ToBuy> createState() => _ToBuyState();
}

class _ToBuyState extends State<ToBuy> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BasicScreenWidget(
      child: TagDataProvider(
        builder: (context, tagData) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ToBuyTitle(),
            const SizedBox(height: 16.0),
            Expanded(child: ToBuyBody(onChanged: (v) {})),

            /// Insets for the navbar.
            shrinkingNavigationOffset,
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ToBuyTitle extends StatelessWidget {
  const ToBuyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 32.0) + const EdgeInsets.symmetric(horizontal: 32.0),
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
  const ToBuyBody({
    required this.onChanged,
    super.key,
  });

  static List<(Color, String)> toBuyList = [
    (TagColors.selectable[2], "Tomato Sauce"),
    (TagColors.selectable[0], "Onions"),
    (TagColors.selectable[0], "Potatoes"),
    (TagColors.selectable[0], "Carrots"),
    (TagColors.selectable[0], "Garlic"),
    (TagColors.selectable[0], "Garlic chips"),
    (TagColors.selectable[0], "Garlic powder"),
    (TagColors.selectable[0], "Cooking Oil"),
    (TagColors.selectable[9], "Ketchup"),
    (TagColors.selectable[9], "Soy Sauce"),
  ];
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: ColoredBox(
          color: FigmaColors.whiteAccent,
          child: Column(
            children: [
              Expanded(
                child: MouseSingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        for (int index = 0; index < toBuyList.length; ++index) ...[
                          if (index > 0)
                            const Divider(
                              color: FigmaColors.lightGreyAccent,
                              thickness: 1.0,
                            ),
                          ToBuyTile(entry: toBuyList[index], onChanged: onChanged),
                        ],
                      ],
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
}

class ToBuyTile extends StatefulWidget {
  const ToBuyTile({
    required this.entry,
    required this.onChanged,
    super.key,
  });

  final (Color, String) entry;

  // ignore: avoid_positional_boolean_parameters
  final void Function(bool p1)? onChanged;

  @override
  State<ToBuyTile> createState() => _ToBuyTileState();
}

class _ToBuyTileState extends State<ToBuyTile> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    var (color, itemName) = widget.entry;

    return CheckBox(
      color: color,
      itemNameToBuy: itemName,
      itemObtainStatus: isActive,
      onChanged: (bool val) {
        setState(() {
          isActive = !isActive;
        });
        widget.onChanged?.call(isActive);
      },
    );
  }
}
