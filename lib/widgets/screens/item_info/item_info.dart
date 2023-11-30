import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";

class ItemInfo extends StatefulWidget {
  const ItemInfo({super.key});

  @override
  State<ItemInfo> createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> {
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
                  TagDataProvider(
                    builder: (context, tagData) => const TagsView(),
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
