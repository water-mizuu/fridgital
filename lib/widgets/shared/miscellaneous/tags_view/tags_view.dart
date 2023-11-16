import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
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
}

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> with TickerProviderStateMixin {
  void Function() tapHandler(BuildContext context, BoxConstraints constraints) {
    return () {
      if (!context.mounted) {
        return;
      }

      var tagData = context.read<TagData>();
      var animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
      var overlayConstraints = BoxConstraints(maxWidth: constraints.maxWidth * 0.9);
      var overlayMode = ValueNotifier(OverlayMode.select);

      late OverlayEntry entry;

      void dispose() {
        animationController.dispose();
        entry.remove();
      }

      void init() {
        Overlay.of(context).insert(entry);
        animationController.forward();
      }

      entry = OverlayEntry(
        maintainState: true,
        builder: (_) => NotificationListener<OverlayNotification>(
          onNotification: (notification) {
            unawaited(() async {
              switch (notification) {
                transition_to_select:
                case SwitchToSelectOverlayNotification():
                  await animationController.reverse(from: 1.0);
                  overlayMode.value = OverlayMode.select;
                  await animationController.forward();
                case SwitchToAddOverlayNotification():
                  await animationController.reverse(from: 1.0);
                  overlayMode.value = OverlayMode.add;
                  await animationController.forward();

                case SelectedTagOverlayNotification(:Tag tag):
                  await animationController.reverse();
                  tagData.addTag(tag);
                  dispose();
                case CloseOverlayNotification():
                  await animationController.reverse(from: 1.0);
                  dispose();
                case CreateNewTagOverlayNotification(:var name, :var color):
                  var tag = CustomTag(name, color);
                  tagData.addableTags.add(tag);

                  continue transition_to_select;
              }
            }());

            return true;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              await animationController.reverse();
              dispose();
            },
            child: Scaffold(
              backgroundColor: const Color(0x7fCCAEBB),
              body: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: ValueListenableBuilder(
                  valueListenable: overlayMode,
                  builder: (context, overlayMode, child) => Center(
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) => Opacity(
                        opacity: animationController.value,
                        child: Transform.scale(
                          scale: (0.8 + animationController.value).clamp(0.0, 1.0),
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: overlayConstraints,
                            child: child,
                          ),
                        ),
                      ),
                      child: switch (overlayMode) {
                        OverlayMode.select => SelectTagOverlay(tagData: tagData),
                        OverlayMode.add => CreateTagOverlay(tagData: tagData),
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
    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ClickableWidget(
          onTap: tapHandler(context, constraints),
          child: Container(
            height: _tagHeight,
            color: TagColors.selector,
            child: const IgnorePointer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
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
            const SizedBox(height: 8.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 312),
              child: switch (availableTags.length) {
                0 => const SizedBox(),
                _ => MouseSingleChildScrollView(
                    child: Wrap(
                      runSpacing: 8.0,
                      children: [
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
            const SizedBox(height: 16.0),
            _TagWidget(
              tag: const CustomTag("Create a new tag", TagColors.addButton),
              icon: Icons.add,
              onTap: () => const SwitchToAddOverlayNotification().dispatch(context),
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
                builder: (context, controller, physics) {
                  var colors = TagColors.selectable.iterable.toList();

                  return GridView.builder(
                    controller: controller,
                    physics: physics,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                    itemCount: colors.length,
                    itemBuilder: (context, index) => ClickableWidget(
                      onTap: () {
                        selectedColor.value = colors[index];
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Center(
                            child: Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[index],
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: selectedColor,
                                builder: (context, selectedColor, child) => selectedColor != colors[index]
                                    ? const SizedBox()
                                    : Center(
                                        child: Container(
                                          width: constraints.maxWidth * 0.9,
                                          height: constraints.maxHeight * 0.9,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedColor == colors[index] //
                                                ? FigmaColors.whiteAccent
                                                : colors[index],
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: constraints.maxWidth * 0.75,
                                              height: constraints.maxHeight * 0.75,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: colors[index],
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
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            _TagWidget(
              tag: const CustomTag("Add new tag", TagColors.addButton),
              icon: Icons.add,
              onTap: () {
                if (selectedColor.value case UserSelectableColor color) {
                  if (textEditingController case TextEditingController(:var text) when text.isNotEmpty) {
                    CreateNewTagOverlayNotification(color: color, name: text).dispatch(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Represents a simple removable tag.
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
