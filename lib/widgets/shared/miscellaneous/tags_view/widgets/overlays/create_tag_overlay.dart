// TODO(water-mizuu): Refactor this whole file.

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class CreateTagOverlay extends StatefulWidget {
  const CreateTagOverlay({super.key});

  @override
  State<CreateTagOverlay> createState() => _CreateTagOverlayState();
}

class _CreateTagOverlayState extends State<CreateTagOverlay> {
  late final FocusNode focusNode;
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    selectedColor.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ClickableWidget(
                      onTap: () {
                        const CloseOverlayNotification().dispatch(context);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      autofocus: true,
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: "Tag name",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 312),
              child: MouseScroll<ScrollController>(
                builder: (context, controller, physics) => GridView.builder(
                  controller: controller,
                  physics: physics,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                  itemCount: TagColors.selectable.length,
                  itemBuilder: (context, index) {
                    var color = TagColors.selectable[index];

                    return ClickableWidget(
                      onTap: () {
                        selectedColor.value = color;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Center(
                            child: Container(
                              width: constraints.maxWidth * 0.9,
                              height: constraints.maxHeight * 0.9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: selectedColor,
                                builder: (context, selectedColor, child) => //
                                    selectedColor != color
                                        ? const SizedBox()
                                        : Center(
                                            child: Container(
                                              width: constraints.maxWidth * 0.8375,
                                              height: constraints.maxHeight * 0.8375,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selectedColor == color //
                                                    ? FigmaColors.whiteAccent
                                                    : color,
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: constraints.maxWidth * 0.7,
                                                  height: constraints.maxHeight * 0.7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                TagWidget(
                  tag: const CustomTag("Add", TagColors.addButton),
                  icon: Icons.add,
                  onTap: () {
                    var color = selectedColor.value;
                    if (color == null) {
                      var snackbar = SnackBar(content: const Text("Please select a color"), duration: 2.s);

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    var text = textEditingController.text;
                    if (text.isEmpty) {
                      var snackbar = SnackBar(content: const Text("Please enter a name"), duration: 2.s);

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    if (context.read<TagData>().addableTags.any((v) => v.name == text)) {
                      var snackbar = SnackBar(
                        content: Text("A tag with the name '$text' already exists!"),
                        duration: 2.s,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    CreateNewTagOverlayNotification(color: color, name: text).dispatch(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
