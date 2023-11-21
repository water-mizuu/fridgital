import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> with AutomaticKeepAliveClientMixin {
  late final Future<TagData> loadingTagData;

  @override
  void initState() {
    super.initState();

    loadingTagData = TagData.emptyFromDatabase();
  }

  @override
  void dispose() {
    unawaited(() async {
      var tagData = await loadingTagData;
      tagData.dispose();
    }());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BasicScreenWidget(
      child: FutureBuilder(
        future: loadingTagData,
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
