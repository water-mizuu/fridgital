import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> with AutomaticKeepAliveClientMixin, EmptyTagDataMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BasicScreenWidget(
      child: FutureBuilder(
        future: tagDataFuture,
        builder: (context, snapshot) => switch (snapshot) {
          AsyncSnapshot(connectionState: ConnectionState.done, hasData: true, :var data!) => //
            ChangeNotifierProvider.value(
              value: data,
              child: const MouseSingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InventoryTitle(),
                    SizedBox(height: 16.0),
                    InventoryTags(),
                    SizedBox(height: 16.0),
                    InventoryTabs(),
                  ],
                ),
              ),
            ),
          AsyncSnapshot(connectionState: ConnectionState.done, hasError: true, :var error!) =>
            Center(child: Text(error.toString())),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class InventoryTitle extends StatelessWidget {
  const InventoryTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 32.0) + const EdgeInsets.symmetric(horizontal: 32.0),
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

class InventoryTags extends StatelessWidget {
  const InventoryTags({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: TagsView(),
    );
  }
}

enum InventoryTab { freezer, refrigerator, pantry }

class InventoryTabs extends StatefulWidget {
  const InventoryTabs({super.key});

  @override
  State<InventoryTabs> createState() => _InventoryTabsState();
}

class _InventoryTabsState extends State<InventoryTabs> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.black,
                fontFamily: "Nunito",
                fontWeight: FontWeight.w700,
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
        ),

        /// This is where the tabs are.
      ],
    );
  }
}
