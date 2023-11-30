import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/checkbox_tile.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
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
            const ToBuyTags(),
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

class ToBuyTags extends StatelessWidget {
  const ToBuyTags({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: TagsView(),
    );
  }
}

class ToBuyBody extends StatelessWidget {
  const ToBuyBody({
    required this.onChanged,
    super.key,
  });

  static List<String> toBuyList = [
    "hi",
    "bye",
    "good hello",
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
                          ToBuyTile(toBuyList: toBuyList, index: index, onChanged: onChanged),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 8.0, bottom: 15.0, top: 8.0),
                child: ClickableWidget(
                  onTap: () {
                    if (kDebugMode) {
                      print("Deez nuts. Gotteem");
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: FigmaColors.lightGreyAccent,
                      ),
                      Text(
                        "Add Item...",
                        style: TextStyle(
                          color: FigmaColors.lightGreyAccent,
                          fontStyle: FontStyle.italic,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
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
    required this.toBuyList,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<String> toBuyList;
  final int index;

  // ignore: avoid_positional_boolean_parameters
  final void Function(bool p1)? onChanged;

  @override
  State<ToBuyTile> createState() => _ToBuyTileState();
}

class _ToBuyTileState extends State<ToBuyTile> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return CheckBox(
      itemNameToBuy: widget.toBuyList[widget.index],
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
