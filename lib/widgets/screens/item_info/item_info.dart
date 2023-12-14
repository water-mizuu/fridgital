import "package:flutter/foundation.dart";
import "package:flutter/material.dart" hide BackButton;
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/classes/reference.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/hooks/use_post_render.dart";
import "package:fridgital/shared/hooks/use_reference.dart";
import "package:fridgital/shared/utils.dart" as utils;
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/back_button.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_data_provider.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class ItemInfo extends HookWidget {
  const ItemInfo({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var addedDate = useReference<DateTime?>(product.addedDate);
    var tags = useReference<List<Tag>>(product.tags.toList());
    var storageUnits = useReference<String>(product.storageUnits);
    var expiryDate = useReference<DateTime?>(product.expiryDate);
    var image = useReference<Uint8List?>(product.imageBytes);
    var notes = useReference<String>(product.notes);

    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        body: BasicScreenWidget(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const ItemInfoTitle(),
                const SizedBox(height: 8.0),
                ItemInfoTags(tags: tags),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ItemFields(
                    addedDate: addedDate,
                    storageUnits: storageUnits,
                    expiryDate: expiryDate,
                    image: image,
                    notes: notes,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemFields extends HookWidget {
  const ItemFields({
    required this.addedDate,
    required this.storageUnits,
    required this.expiryDate,
    required this.image,
    required this.notes,
    super.key,
  });

  final Reference<DateTime?> addedDate;
  final Reference<String> storageUnits;
  final Reference<DateTime?> expiryDate;
  final Reference<Uint8List?> image;
  final Reference<String> notes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: MouseSingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItemInfoImageField(
              title: "Image",
              reference: image,
              description: context.select((Product product) => product.description),
            ),
            ItemInfoDateField(
              title: "Date Added",
              reference: addedDate,
            ),
            ItemInfoTextField(
              title: "Storage Units",
              reference: storageUnits,
            ),
            ItemInfoDateField(
              title: "Expiry Date",
              reference: expiryDate,
            ),
            ItemInfoTextAreaField(
              title: "Notes",
              reference: notes,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemInfoTitle extends HookWidget {
  const ItemInfoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var (name, id) = context.select((Product product) => (product.name, product.id));

    var focusNode = useFocusNode();
    var textEditingController = useState(null as TextEditingController?);

    var focus = usePostRenderCallback(() {
      focusNode.requestFocus();
    });
    var completeEdit = useCallback(() async {
      var productData = context.read<ProductData>();

      assert(textEditingController.value != null, "This should only be called when editing is enabled.");
      if (textEditingController.value case var controller?
          when productData.products.any((product) => product.id == id)) {
        await productData.renameProduct(id: id, name: controller.text.toUpperCase());
      }
      textEditingController.value = null;
    });

    useEffect(
      () => () => textEditingController.value?.dispose(),
      [],
    );

    return Row(
      children: [
        BackButton(
          isBig: true,
          onTap: () {
            RouteState.of(context).workingProduct = null;
          },
        ),
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              textEditingController.value = TextEditingController(text: name.toUpperCase());
              focus();
            },
            child: TextField(
              controller: textEditingController.value ?? TextEditingController(text: name.toUpperCase()),
              focusNode: focusNode,
              autofocus: true,
              showCursor: true,
              onEditingComplete: completeEdit,
              onTapOutside: (_) async => await completeEdit(),
              enabled: textEditingController.value != null,
              style: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                Color color = states.contains(MaterialState.disabled) //
                    ? Colors.black
                    : Colors.black87;

                return TextStyle(
                  color: color,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w800,
                );
              }),
              decoration: const InputDecoration(
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                UpperCaseTextFormatter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ItemInfoTags extends StatelessWidget {
  const ItemInfoTags({
    required this.tags,
    super.key,
  });

  final Reference<List<Tag>> tags;

  @override
  Widget build(BuildContext context) {
    var productData = context.read<ProductData>();
    var product = context.read<Product>();

    return Align(
      alignment: Alignment.centerLeft,
      child: TagDataProvider(
        initialTags: this.tags.value,
        onTagAdd: (tag) async {
          await productData.addProductTag(id: product.id, tag: tag);
        },
        onTagRemove: (tag) async {
          if (kDebugMode) {
            print("Removing tag $tag from product ${product.id}.");
          }
          await productData.removeProductTag(id: product.id, tag: tag);
        },
        builder: (context, tagData) {
          return const TagsView();
        },
      ),
    );
  }
}

class ItemInfoImageField extends HookWidget {
  const ItemInfoImageField({
    required this.title,
    required this.reference,
    required this.description,
    super.key,
  });

  final String title;
  final Reference<Uint8List?> reference;
  final String? description;

  @override
  Widget build(BuildContext context) {
    var bytes = useState(reference.value);
    var id = context.select((Product product) => product.id);

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
              child: ClickableWidget(
                onTap: () async {
                  var image = await utils.pickImage();
                  if (!context.mounted) {
                    return;
                  }

                  if (image == null) {
                    return;
                  }

                  reference.value = bytes.value = image;
                  await context
                      .read<ProductData>() //
                      .updateProductImage(id: id, image: image);
                },
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
                        if (bytes.value case var bytes?) ...[
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
            ),
            if (description case var description?)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: FigmaColors.darkGreyAccent, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ItemInfoTextField extends HookWidget {
  const ItemInfoTextField({
    required this.title,
    required this.reference,
    super.key,
  });

  final String title;
  final Reference<String> reference;

  @override
  Widget build(BuildContext context) {
    var textEditingController = useTextEditingController(text: reference.value);

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

class ItemInfoTextAreaField extends StatefulWidget {
  const ItemInfoTextAreaField({
    required this.title,
    required this.reference,
    super.key,
  });

  final String title;
  final Reference<String> reference;

  @override
  State<ItemInfoTextAreaField> createState() => _ItemInfoTextAreaFieldState();
}

class _ItemInfoTextAreaFieldState extends State<ItemInfoTextAreaField> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(text: widget.reference.value)
      ..addListener(() {
        widget.reference.value = textEditingController.text;
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
              minLines: 2,
              maxLines: null,
              controller: textEditingController,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemInfoDateField extends StatefulWidget {
  const ItemInfoDateField({required this.title, required this.reference, this.initialDate, super.key});

  final Reference<DateTime?> reference;
  final DateTime? initialDate;
  final String title;

  @override
  State<ItemInfoDateField> createState() => _ItemInfoDateFieldState();
}

class _ItemInfoDateFieldState extends State<ItemInfoDateField> {
  late final ValueNotifier<DateTime?> dateTime;

  @override
  void initState() {
    super.initState();

    dateTime = ValueNotifier<DateTime?>(widget.reference.value ?? widget.initialDate)
      ..addListener(() {
        widget.reference.value = dateTime.value;
      });
    widget.reference.value = widget.initialDate;
  }

  @override
  void dispose() {
    dateTime.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var productData = context.read<ProductData>();
    var product = context.read<Product>();

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
                        initialDate: dateTime.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date == null || !context.mounted) {
                        return;
                      }

                      if (productData.products.any((p) => p.id == product.id)) {
                        await productData.updateProduct(id: product.id, (product) {});
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
                          null => const [
                              TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                              TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              TextSpan(text: "00", style: TextStyle(color: Colors.transparent)),
                              TextSpan(text: "/", style: TextStyle(color: FigmaColors.textDark)),
                              TextSpan(text: "0000", style: TextStyle(color: Colors.transparent)),
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
