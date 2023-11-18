import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/notifications.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

const _tagIconSize = 14.0;
const _tagHeight = 32.0;
const _tagGapToIcon = 16.0;

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    var tagData = context.watch<TagData>();

    return Wrap(
      runSpacing: 8.0,
      children: [
        for (var tag in tagData.activeTags)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: _TagWidget(
              tag: tag,
              onTap: () {
                tagData.removeTag(tag);
              },
            ),
          ),
        const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: TagSelector(),
        ),
      ],
    );
  }
}

enum OverlayMode {
  select,
  add,
  selectDelete,
  delete,
  selectEdit,
  edit,
}

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> with TickerProviderStateMixin {
  void Function() tapHandler(BuildContext context) {
    return () {
      if (!context.mounted) {
        return;
      }

      var tagData = context.read<TagData>();
      var animationController = AnimationController(vsync: this, duration: 250.ms);
      var overlayMode = ValueNotifier(OverlayMode.select);

      OverlayEntry? entry;

      Future<void> transitionTo(OverlayMode mode) async {
        await animationController.reverse(from: 1.0);
        overlayMode.value = mode;
        await animationController.forward(from: 0.0);
      }

      void dispose() {
        animationController.dispose();
        entry?.remove();
      }

      void init() {
        if (entry case var entry?) {
          Overlay.of(context).insert(entry);
          animationController.forward(from: 0.0);
        }
      }

      entry = OverlayEntry(
        maintainState: true,
        builder: (_) => NotificationListener<OverlayNotification>(
          onNotification: (notification) {
            unawaited(() async {
              switch (notification) {
                case SwitchOverlayNotification(:var mode):
                  await transitionTo(mode);

                case SelectedTagOverlayNotification(:Tag tag):
                  await animationController.reverse(from: 1.0);
                  tagData.addTag(tag);
                  dispose();
                case CloseOverlayNotification():
                  await animationController.reverse(from: 1.0);
                  dispose();
                case CreateNewTagOverlayNotification(:var name, :var color):
                  var tag = CustomTag(name, color);
                  tagData.addableTags.add(tag);

                  await transitionTo(OverlayMode.select);
              }
            }());

            return true;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              await animationController.reverse(from: 1.0);
              dispose();
            },
            child: Scaffold(
              backgroundColor: const Color(0x7fCCAEBB),
              body: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: ListenableBuilder(
                  listenable: overlayMode,
                  builder: (context, child) => Center(
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) => Opacity(
                        opacity: animationController.value,
                        child: Transform.scale(
                          scale: (0.8 + 0.4 * animationController.value).clamp(0.0, 1.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.95),
                            child: child,
                          ),
                        ),
                      ),
                      child: switch (overlayMode.value) {
                        OverlayMode.select => SelectTagOverlay(tagData: tagData),
                        OverlayMode.add => CreateTagOverlay(tagData: tagData),
                        OverlayMode.edit => EditTagOverlay(tagData: tagData),
                        OverlayMode.selectEdit => SelectTagOverlay(tagData: tagData),
                        OverlayMode.delete => DeleteTagOverlay(tagData: tagData),
                        OverlayMode.selectDelete => SelectDeleteOverlay(tagData: tagData),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      init();
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        onTap: tapHandler(context),
        child: Container(
          height: _tagHeight,
          color: TagColors.selector,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const IgnorePointer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("filter", style: TextStyle(color: Colors.white)),
                SizedBox(width: _tagGapToIcon),
                Icon(Icons.add, size: _tagIconSize, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectTagOverlay extends StatelessWidget {
  const SelectTagOverlay({required this.tagData, super.key});

  final TagData tagData;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var TagData(:activeTags, :addableTags) = tagData;
    var availableTags = addableTags.difference(activeTags);

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
                      onTap: () => const CloseOverlayNotification().dispatch(context),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Text(
                    "SELECT A TAG",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 284.0),
              child: switch (availableTags.length) {
                0 => const SizedBox(),
                _ => MouseSingleChildScrollView(
                    child: Wrap(
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < 12; ++i)
                          for (var tag in availableTags)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: _TagWidget(
                                tag: tag,
                                icon: null,
                                onTap: () => SelectedTagOverlayNotification(tag).dispatch(context),
                              ),
                            ),
                      ],
                    ),
                  ),
              },
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconWidget(
                  color: TagColors.addButton,
                  icon: Icons.add,
                  onTap: () => const SwitchOverlayNotification(mode: OverlayMode.add).dispatch(context),
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _IconWidget(
                  color: TagColors.addButton,
                  icon: Icons.edit,
                  onTap: () {},
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _IconWidget(
                  color: const Color(0x7f85100D),
                  icon: Icons.delete_outline,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateTagOverlay extends StatefulWidget {
  const CreateTagOverlay({
    required this.tagData,
    super.key,
  });

  final TagData tagData;

  @override
  State<CreateTagOverlay> createState() => _CreateTagOverlayState();
}

class _CreateTagOverlayState extends State<CreateTagOverlay> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);
  }

  @override
  void dispose() {
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
                _IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _TagWidget(
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

                    print((color, text));

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

// TODO(water-mizuu): Work on this
class EditTagOverlay extends StatefulWidget {
  const EditTagOverlay({
    required this.tagData,
    super.key,
  });

  final TagData tagData;

  @override
  State<EditTagOverlay> createState() => _EditTagOverlayState();
}

class _EditTagOverlayState extends State<EditTagOverlay> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);
  }

  @override
  void dispose() {
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
                _IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _TagWidget(
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

                    print((color, text));

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

// TODO(water-mizuu): Work on this
class SelectEditOverlay extends StatefulWidget {
  const SelectEditOverlay({
    required this.tagData,
    super.key,
  });

  final TagData tagData;

  @override
  State<SelectEditOverlay> createState() => _SelectEditOverlayState();
}

class _SelectEditOverlayState extends State<SelectEditOverlay> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);
  }

  @override
  void dispose() {
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
                _IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _TagWidget(
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

                    print((color, text));

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

// TODO(water-mizuu): Work on this
class DeleteTagOverlay extends StatefulWidget {
  const DeleteTagOverlay({
    required this.tagData,
    super.key,
  });

  final TagData tagData;

  @override
  State<DeleteTagOverlay> createState() => _DeleteTagOverlayState();
}

class _DeleteTagOverlayState extends State<DeleteTagOverlay> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);
  }

  @override
  void dispose() {
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
                _IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _TagWidget(
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

                    print((color, text));

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

// TODO(water-mizuu): Work on this
class SelectDeleteOverlay extends StatefulWidget {
  const SelectDeleteOverlay({
    required this.tagData,
    super.key,
  });

  final TagData tagData;

  @override
  State<SelectDeleteOverlay> createState() => _SelectDeleteOverlayState();
}

class _SelectDeleteOverlayState extends State<SelectDeleteOverlay> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<UserSelectableColor?> selectedColor;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    selectedColor = ValueNotifier(null);
  }

  @override
  void dispose() {
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
                _IconWidget(
                  icon: Icons.arrow_back,
                  color: TagColors.addButton,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                _TagWidget(
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

                    print((color, text));

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

/// Represents a simple removable tag that is composed of only an icon.
class _IconWidget extends StatelessWidget {
  const _IconWidget({required this.color, required this.icon, this.onTap});

  final Color color;
  final IconData? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        onTap: onTap,
        child: Container(
          color: color,
          height: _tagHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(icon, size: _tagIconSize, color: Colors.white),
        ),
      ),
    );
  }
}

/// Represents a simple removable tag that is composed of text with an optional icon.
class _TagWidget extends StatelessWidget {
  const _TagWidget({required this.tag, this.icon = Icons.close, this.onTap});

  final Tag tag;
  final IconData? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        onTap: onTap,
        child: SizedBox(
          height: _tagHeight,
          child: Material(
            color: tag.color,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: icon == null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(tag.name, style: const TextStyle(color: Colors.white))],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.name, style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: _tagGapToIcon),
                        Icon(icon, size: _tagIconSize, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
