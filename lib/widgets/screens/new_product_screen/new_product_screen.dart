import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/reference.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/utils.dart" as utils;
import "package:fridgital/shared/utils.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:functional_widget_annotation/functional_widget_annotation.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

part "new_product_screen.g.dart";

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  late final Reference<String> name;
  late final Reference<DateTime?> addedDate;
  late final Reference<String> storageUnits;
  late final Reference<DateTime?> expiryDate;
  late final Reference<String> notes;
  late final Reference<Uint8List?> image;

  T unwrap<T>(Reference<T> reference, String name, {bool isEmptyAllowed = false}) {
    var value = reference.value;
    if (!isEmptyAllowed && ((value == null) || (value is String && value.isEmpty))) {
      var message = "Field '$name' should not be empty!";
      var snackbar = SnackBar(content: Text(message));

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      throw const FormValidationFailure();
    }

    return value;
  }

  void pickImage() async {
    var image = await utils.pickImage();

    if (!context.mounted || image == null) {
      return;
    }

    this.image.value = image;
  }

  Future<void> submit(TagData tagData) async {
    var tags = tagData.activeTags.toList();

    if (!context.mounted) {
      return;
    }

    try {
      late var today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      var name = unwrap(this.name, "Name");
      var addedDate = unwrap(this.addedDate, "Date Added");
      var storageUnits = unwrap(this.storageUnits, "Storage Units");
      var expiryDate = unwrap(this.expiryDate, "Expiry Date");
      var notes = unwrap(this.notes, "Notes", isEmptyAllowed: true);
      var image = unwrap(this.image, "Image URL", isEmptyAllowed: true);

      var productData = context.read<ProductData>();

      await productData.addProduct(
        name: name,
        addedDate: addedDate ?? today,
        storageUnits: storageUnits,
        storageLocation: context.read<StorageLocation>(),
        expiryDate: expiryDate,
        notes: notes,
        tags: tags,
        image: image,
      );
      if (!context.mounted) {
        return;
      }
      RouteState.of(context).isCreatingNewProduct = false;
    } on FormValidationFailure {
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    name = Reference("");
    image = Reference(null as Uint8List?);
    addedDate = Reference(null as DateTime?);
    storageUnits = Reference("Pounds");
    expiryDate = Reference(null);
    notes = Reference("");
  }

  @override
  void dispose() {
    name.dispose();
    image.dispose();
    addedDate.dispose();
    storageUnits.dispose();
    expiryDate.dispose();
    notes.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TagDataProvider(
        builder: (context, tagData) {
          return BasicScreenWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Center(
                          child: ClickableWidget(
                            onTap: () {
                              RouteState.of(context).toggleCreatingNewProduct();
                            },
                            child: const Icon(Icons.arrow_back_ios_rounded),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text("Inventory".toUpperCase(), style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: TagsView(),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: MouseSingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ProductImageField(title: "Image"),
                          ProductTextField(
                            title: "Name",
                            reference: name,
                            mapper: (name) => name,
                          ),
                          ProductDateField(
                            title: "Date Added",
                            reference: addedDate,
                          ),
                          ProductTextField(
                            title: "Storage Units",
                            reference: storageUnits,
                            mapper: (units) => units,
                          ),
                          ProductDateField(
                            title: "Expiry Date",
                            reference: expiryDate,
                          ),
                          ProductTextField(
                            title: "Notes",
                            reference: notes,
                            mapper: (name) => name,
                          ),
                          TextButton(
                            onPressed: () async => submit(tagData),
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

@hwidget
Widget productImageField(BuildContext context, {required String title}) {
  var bytes = useState(null as Uint8List?);

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
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClickableWidget(
              onTap: () async {
                var image = await pickImage();
                if (!context.mounted) {
                  return;
                }

                bytes.value = image;
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: FigmaColors.expiryWidgetBackground2, width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      if (bytes.value case var bytes?) ...[
                        Image.memory(bytes, fit: BoxFit.cover, width: 128.0),
                        const Text("CHANGE PHOTO", style: TextStyle(color: FigmaColors.expiryWidgetBackground2)),
                      ] else ...[
                        const Icon(Icons.camera_alt, size: 48.0, color: FigmaColors.expiryWidgetBackground2),
                        const Text("ADD A PHOTO", style: TextStyle(color: FigmaColors.expiryWidgetBackground2)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductTextField<T, VT extends Reference<T>> extends StatefulWidget {
  const ProductTextField({
    required this.title,
    required this.reference,
    required this.mapper,
    super.key,
  });

  final String title;
  final VT reference;
  final T Function(String) mapper;

  @override
  State<ProductTextField<T, VT>> createState() => _ProductTextFieldState<T, VT>();
}

class _ProductTextFieldState<T, VT extends Reference<T>> extends State<ProductTextField<T, VT>> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController()
      ..addListener(() {
        widget.reference.value = widget.mapper(textEditingController.text);
      });
  }

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

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
              child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
            ),
            TextField(
              textAlign: TextAlign.right,
              controller: textEditingController,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDateField extends StatefulWidget {
  const ProductDateField({required this.title, required this.reference, super.key});

  final Reference<DateTime?> reference;
  final String title;

  @override
  State<ProductDateField> createState() => _ProductDateFieldState();
}

class _ProductDateFieldState extends State<ProductDateField> {
  late final ValueNotifier<DateTime?> dateTime;

  @override
  void initState() {
    super.initState();

    dateTime = ValueNotifier<DateTime?>(null)
      ..addListener(() {
        widget.reference.value = dateTime.value;
      });
  }

  @override
  void dispose() {
    dateTime.dispose();

    super.dispose();
  }

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
              child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20.0, color: FigmaColors.lightGreyAccent),
                  const SizedBox(width: 12.0),
                  ClickableWidget(
                    onTap: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date == null) {
                        return;
                      }

                      dateTime.value = date;
                    },
                    child: ListenableBuilder(
                      listenable: dateTime,
                      builder: (context, _) {
                        var date = switch (dateTime.value?.toLocal()) {
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
                        };

                        return Text.rich(
                          TextSpan(children: date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20.0,
                            decoration: TextDecoration.underline,
                          ),
                        );
                        // return Text(
                        //   style: const TextStyle(
                        //     fontWeight: FontWeight.w800,
                        //     fontSize: 20.0,
                        //     decoration: TextDecoration.underline,
                        //     fontFamily: "Operator Mono",
                        //   ),
                        // );
                      },
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

class FormValidationFailure implements Exception {
  const FormValidationFailure();
}
