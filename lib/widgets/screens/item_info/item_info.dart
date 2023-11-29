import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:provider/provider.dart";

class ItemInfo extends StatefulWidget {
  const ItemInfo({super.key});

  @override
  State<ItemInfo> createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> with EmptyTagDataMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasicScreenWidget(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    color: FigmaColors.textDark,
                    size: 50,
                  ),
                  Text(
                    "Title",
                    style: TextStyle(color: FigmaColors.textDark, fontSize: 50, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Row(
                children: [
                  FutureBuilder(
                    future: tagDataFuture,
                    builder: (context, snapshot) => switch (snapshot) {
                      AsyncSnapshot(connectionState: ConnectionState.done, hasData: true, :var data!) =>
                        ChangeNotifierProvider.value(
                          value: data,
                          child: const TagsView(),
                        ),
                      AsyncSnapshot(connectionState: ConnectionState.done, hasError: true, :var error!) =>
                        Text(error.toString()),
                      AsyncSnapshot() => const CircularProgressIndicator.adaptive(),
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
