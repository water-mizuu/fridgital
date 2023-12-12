import "dart:typed_data";

import "package:flutter/material.dart" hide BackButton;
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/back_button.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";

class ItemInfo extends StatelessWidget {
  const ItemInfo({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasicScreenWidget(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(
                    isBig: true,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: FigmaColors.textDark, fontSize: 50, fontWeight: FontWeight.w900),
                    ),
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
              const SizedBox(height: 16.0),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MouseSingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProductImageField(
                          bytes: product.imageBytes,
                          description: product.description ?? "",
                        ),
                        ImmutableProductDateField(
                          title: "Date Added",
                          date: DateTime(2023, 9, 19),
                        ),
                        const ImmutableProductTextField(
                          title: "Storage Units",
                          content: "100 lbs",
                        ),
                        ImmutableProductDateField(
                          title: "Expiry Date",
                          date: product.expiryDate,
                        ),
                        ImmutableProductTextField(
                          title: "Notes",
                          content: switch (product.notes) {
                            "" => "No notes",
                            var notes => notes,
                          },
                        ),
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

class ProductImageField extends StatelessWidget {
  const ProductImageField({
    required this.bytes,
    required this.description,
    super.key,
  });

  final Uint8List? bytes;
  final String description;

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
            Text(
              description,
              maxLines: 4,
              style: const TextStyle(
                color: FigmaColors.darkGreyAccent,
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
        padding: const EdgeInsets.all(8.0) - const EdgeInsets.only(bottom: 8.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
            Text(
              content,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
              ),
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
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20.0, color: FigmaColors.lightGreyAccent),
                  const SizedBox(width: 12.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        ...switch (date?.toLocal()) {
                          var date? => [
                              TextSpan(
                                text: date.month.toString().padLeft(2, "0"),
                                style: const TextStyle(color: FigmaColors.textDark),
                              ),
                              const TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              TextSpan(
                                text: date.day.toString().padLeft(2, "0"),
                                style: const TextStyle(color: FigmaColors.textDark),
                              ),
                              const TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              TextSpan(
                                text: date.year.toString().padLeft(4, "0"),
                                style: const TextStyle(color: FigmaColors.textDark),
                              ),
                            ],
                          null => [
                              const TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                              const TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              const TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                              const TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              const TextSpan(text: "0000", style: TextStyle(color: Colors.transparent)),
                            ],
                        },
                      ],
                      style: const TextStyle(
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
