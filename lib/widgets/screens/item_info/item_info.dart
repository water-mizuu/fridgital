import "dart:typed_data";

import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";

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
              MouseSingleChildScrollView(
                child: Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          width: 375,
                          height: 345,
                          child: DecoratedBox(
                            decoration:
                                BoxDecoration(color: FigmaColors.whiteAccent, borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Image.asset(
                                        "assets/images/potato.jpeg",
                                        width: 335,
                                      ),
                                    ),
                                  ),
                                  const Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 15.0, top: 10),
                                        child: FittedBox(
                                          child: Text(
                                            "Potatoes are underground tubers that grow on the roots of the potato plant, Solanum tuberosum.",
                                            style: TextStyle(
                                              color: FigmaColors.darkGreyAccent,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ImmutableProductDateField(
                        title: "Date Added",
                        // date: "9/19/2023",
                        date: DateTime(2023, 9, 19),
                      ),
                      const ImmutableProductTextField(
                        title: "Storage Units",
                        content: "100 lbs",
                      ),
                      ImmutableProductDateField(
                        title: "Expiry Date",
                        date: DateTime(2023, 9, 19),
                      ),
                      const ImmutableProductTextField(
                        title: "Notes",
                        content: "",
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

class ProductImageField extends StatelessWidget {
  const ProductImageField({required this.title, required this.bytes, super.key});

  final String title;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(8.0)), // For the outer box.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: FigmaColors.expiryWidgetBackground2,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      if (bytes case var bytes?) ...[
                        Image.memory(bytes, fit: BoxFit.cover, width: 256.0),
                        const SizedBox(height: 16.0),
                        const Text(
                          "CHANGE PHOTO",
                          style: TextStyle(color: FigmaColors.expiryWidgetBackground2),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.camera_alt,
                          size: 48.0,
                          color: FigmaColors.expiryWidgetBackground2,
                        ),
                        const Text(
                          "ADD A PHOTO",
                          style: TextStyle(color: FigmaColors.expiryWidgetBackground2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImmutableProductTextField extends StatelessWidget {
  const ImmutableProductTextField({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
            ),
            Text(
              content,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}

class ImmutableProductDateField extends StatelessWidget {
  const ImmutableProductDateField({required this.date, required this.title, super.key});

  final DateTime? date;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0) - const EdgeInsets.only(bottom: 8.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20.0, color: FigmaColors.lightGreyAccent),
                  SizedBox(width: 12.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                        TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                        TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                        TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                        TextSpan(text: "0000", style: TextStyle(color: Colors.transparent)),
                      ],
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
