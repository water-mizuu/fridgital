import "package:flutter/material.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/empty_tag_data_mixin.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/miscellaneous/basic_screen.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> with EmptyTagDataMixin {
  late final ValueNotifier<String> name;
  late final ValueNotifier<String?> imageUrl;
  late final ValueNotifier<DateTime?> addedDate;
  late final ValueNotifier<String> storageUnits;
  late final ValueNotifier<DateTime?> expiryDate;
  late final ValueNotifier<String> notes;

  Future<void> submit() async {
    var tagData = await tagDataFuture;
    var tags = tagData.activeTags.toList();

    if (!context.mounted) {
      return;
    }

    late var today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    var productData = context.read<ProductData>();
    var location = context.read<StorageLocation>();
    await productData.addProduct(
      name: name.value,
      addedDate: addedDate.value ?? today,
      storageUnits: storageUnits.value,
      storageLocation: location,
      expiryDate: expiryDate.value,
      notes: notes.value,
      tags: tags,
      imageUrl: null,
    );
    if (!context.mounted) {
      return;
    }
    RouteState.of(context).isCreatingNewProduct = false;
  }

  @override
  void initState() {
    super.initState();

    name = ValueNotifier<String>("");
    imageUrl = ValueNotifier<String?>(null);
    addedDate = ValueNotifier<DateTime?>(null);
    storageUnits = ValueNotifier<String>("Pounds");
    expiryDate = ValueNotifier<DateTime?>(null);
    notes = ValueNotifier<String>("");
  }

  @override
  void dispose() {
    name.dispose();
    imageUrl.dispose();
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
      body: BasicScreenWidget(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: FutureBuilder(
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
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: MouseSingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NewProductField(
                        title: "Name",
                        valueNotifier: name,
                        mapper: (name) => name,
                      ),
                      NewProductField(
                        title: "Date Added",
                        valueNotifier: addedDate,
                        mapper: (name) => DateTime.tryParse(name),
                      ),
                      NewProductField(
                        title: "Storage Units",
                        valueNotifier: storageUnits,
                        mapper: (units) => units,
                      ),
                      NewProductField(
                        title: "Expiry Date",
                        valueNotifier: expiryDate,
                        mapper: (name) => DateTime.tryParse(name),
                      ),
                      NewProductField(
                        title: "Notes",
                        valueNotifier: notes,
                        mapper: (name) => name,
                      ),
                      TextButton(
                        onPressed: submit,
                        child: const Text("Add"),
                      ),
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

class NewProductField<T, VT extends ValueNotifier<T>> extends StatefulWidget {
  const NewProductField({
    required this.title,
    required this.valueNotifier,
    required this.mapper,
    super.key,
  });

  final String title;
  final VT valueNotifier;
  final T Function(String) mapper;

  @override
  State<NewProductField<T, VT>> createState() => _NewProductFieldState<T, VT>();
}

class _NewProductFieldState<T, VT extends ValueNotifier<T>> extends State<NewProductField<T, VT>> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController()
      ..addListener(() {
        widget.valueNotifier.value = widget.mapper(textEditingController.text);
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
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.0)),
            ),
            TextField(
              controller: textEditingController,
            ),
          ],
        ),
      ),
    );
  }
}
