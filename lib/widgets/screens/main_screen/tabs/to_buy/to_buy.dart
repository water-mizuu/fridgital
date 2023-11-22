import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/checkbox_tile.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/shrinking_navigation.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class ToBuy extends StatefulWidget {
  const ToBuy({super.key});

  @override
  State<ToBuy> createState() => _ToBuyState();
}

class _ToBuyState extends State<ToBuy> with AutomaticKeepAliveClientMixin, EmptyTagDataMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BasicScreenWidget(
      child: FutureBuilder(
        future: tagDataFuture,
        builder: (context, snapshot) => switch (snapshot) {
          AsyncSnapshot(connectionState: ConnectionState.done, hasData: true, :var data!) =>
            ChangeNotifierProvider.value(
              value: data,
              child: Column(
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
          AsyncSnapshot(connectionState: ConnectionState.done, hasError: true, :var error!) =>
            Center(child: Text(error.toString())),
          AsyncSnapshot() => const Center(child: CircularProgressIndicator()),
        },
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

  static List<(String, bool)> toBuyList = [
    ("hi", false),
    ("bye", false),
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
                        for (int i = 0; i < 50; ++i) ...[
                          const Divider(
                            color: FigmaColors.lightGreyAccent,
                            thickness: 1.0,
                          ),

                          ListView.builder(
                            itemCount: toBuyList.length,
                            itemBuilder: (context, index) {
                              return CheckBox(
                                itemNameToBuy: toBuyList[index].$1,
                                itemObtainStatus: toBuyList[index].$2,
                                onChanged: onChanged,
                              );
                            },
                          ),
                          // CheckBox(
                          //   itemNameToBuy: "hi",
                          //   itemObtainStatus: false,
                          //   onChanged: (p0) {},
                          // ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 8.0, bottom: 15.0, top: 8.0),
                child: ClickableWidget(
                  child: Row(
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
