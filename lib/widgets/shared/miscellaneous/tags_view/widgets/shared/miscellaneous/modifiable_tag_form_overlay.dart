import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

final class ModifiableTagFormOverlay extends StatefulWidget {
  const ModifiableTagFormOverlay({
    required this.initialText,
    required this.initialColor,
    required this.onCancel,
    required this.onSubmit,
    required this.bottomButtons,
    required this.confirmationTag,
    required this.confirmationIcon,
    super.key,
  });

  final String? initialText;
  final UserSelectableColor? initialColor;
  final void Function() onCancel;
  final void Function(String name, UserSelectableColor color) onSubmit;

  final CustomTag confirmationTag;
  final IconData? confirmationIcon;

  final List<Widget> bottomButtons;

  @override
  State<ModifiableTagFormOverlay> createState() => _ModifiableTagFormOverlayState();
}

class _ModifiableTagFormOverlayState extends State<ModifiableTagFormOverlay> {
  late final FocusNode focusNode;
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    textEditingController = TextEditingController(text: widget.initialText);
    selectedColor = ValueNotifier(widget.initialColor);

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
                        widget.onCancel();
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
                  itemBuilder: (context, index) => ClickableColorCircle(
                    selectedColor: selectedColor,
                    color: TagColors.selectable[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.bottomButtons.isNotEmpty) ...[
                  for (var (i, button) in widget.bottomButtons.indexed) ...[
                    if (i > 0) const SizedBox(width: 8.0),
                    button,
                  ],
                  const SizedBox(height: 8.0, width: 8.0),
                ],
                TagWidget(
                  tag: widget.confirmationTag,
                  icon: widget.confirmationIcon,
                  onTap: () {
                    var color = selectedColor.value;
                    if (color == null) {
                      var snackbar = SnackBar(
                        content: const Text("Please select a color"),
                        duration: 2.s,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    var text = textEditingController.text;
                    if (text.isEmpty) {
                      var snackbar = SnackBar(
                        content: const Text("Please enter a name"),
                        duration: 2.s,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    var addableTags = context.read<TagData>().addableTags;
                    if (addableTags.any((v) => v.name != widget.initialText && v.name == text)) {
                      var snackbar = SnackBar(
                        content: Text("A tag with the name '$text' already exists!"),
                        duration: 2.s,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    widget.onSubmit(text, color);
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

class ClickableColorCircle extends StatelessWidget {
  const ClickableColorCircle({
    required this.selectedColor,
    required this.color,
    super.key,
  });

  final ValueNotifier<UserSelectableColor?> selectedColor;
  final UserSelectableColor color;

  @override
  Widget build(BuildContext context) {
    const factors = (
      outer: 0.9,
      middle: 0.8375,
      inner: 0.7,
    );

    return ClickableWidget(
      onTap: () {
        selectedColor.value = color;
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: Container(
              width: constraints.maxWidth * factors.outer,
              height: constraints.maxHeight * factors.outer,
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
                              width: constraints.maxWidth * factors.middle,
                              height: constraints.maxHeight * factors.middle,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedColor == color //
                                    ? FigmaColors.whiteAccent
                                    : color,
                              ),
                              child: Center(
                                child: Container(
                                  width: constraints.maxWidth * factors.inner,
                                  height: constraints.maxHeight * factors.inner,
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
  }
}
