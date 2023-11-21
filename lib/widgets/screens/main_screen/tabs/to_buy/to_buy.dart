import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/checkbox_tile.dart";
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ToBuyTitle(),
                  SizedBox(height: 16.0),
                  ToBuyTags(),
                  SizedBox(height: 16.0),
                  Expanded(child: ToBuyBody()),

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
