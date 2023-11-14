import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/helper/change_notifier_builder.dart";
import "package:mouse_scroll/mouse_scroll.dart";

const _tagIconSize = 14.0;
const _tagHeight = 32.0;

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      changeNotifier: TagData.of(context),
      builder: (context, tagData, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              runSpacing: 8.0,
              children: [
                for (var tag in tagData.tags)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: _TagWidget(tag: tag),
                  ),
                const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: TagSelector(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  Widget selectionChip({void Function()? onTap, Color? color}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: SizedBox(
            width: constraints.maxWidth,
            height: _tagHeight,
            child: Material(
              color: color ?? TagColors.selector,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: onTap,
                    child: const IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text("filter", style: TextStyle(color: Colors.white)),
                            Spacer(),
                            Icon(Icons.add, size: _tagIconSize, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return selectionChip(
      onTap: () {
        if (!context.mounted) {
          return;
        }

        var renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox?.localToGlobal(Offset.zero) case Offset left when renderBox != null) {
          late OverlayEntry entry;

          entry = OverlayEntry(
            maintainState: true,
            builder: (context) => NotificationListener<_RemoveOverlayNotification>(
              onNotification: (notification) {
                entry.remove();
                return true;
              },
              child: _TagSelectorOverlay(
                parentSize: renderBox.size,
                parentOffset: left,
                chipBuilder: selectionChip,
              ),
            ),
          );

          Overlay.of(context).insert(entry);
        }
      },
    );
  }
}

class _TagSelectorOverlay extends StatefulWidget {
  const _TagSelectorOverlay({
    required this.parentSize,
    required this.parentOffset,
    required this.chipBuilder,
  });

  final Size parentSize;
  final Offset parentOffset;
  final Widget Function({void Function() onTap}) chipBuilder;

  @override
  State<_TagSelectorOverlay> createState() => _TagSelectorOverlayState();
}

class _TagSelectorOverlayState extends State<_TagSelectorOverlay> with SingleTickerProviderStateMixin {
  static const retractionDuration = Duration(milliseconds: 190);
  static const maxSelectionHeight = 256.0;

  late final AnimationController controller = AnimationController(vsync: this, duration: retractionDuration);
  late Animation<double> retractAnimation = const AlwaysStoppedAnimation(0.0);

  final ValueNotifier<bool> isAnimating = ValueNotifier(false);

  final GlobalKey containerKey = GlobalKey();
  double get width => widget.parentSize.width;

  void open() async {
    if (controller.isAnimating) {
      return;
    }

    var renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox?.size.height case double target) {
      var tween = Tween(begin: 0.0, end: target);

      retractAnimation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn).drive(tween);
      isAnimating.value = true;
    }

    await controller.forward(from: 0.0);
  }

  void close() async {
    if (controller.isAnimating) {
      return;
    }

    await controller.reverse(from: 1.0);
    if (context.mounted) {
      const _RemoveOverlayNotification().dispatch(context);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => open());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: close,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.25),
        body: Transform.translate(
          offset: widget.parentOffset,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: Stack(
              children: [
                ListenableBuilder(
                  listenable: isAnimating,
                  builder: (context, child) => Transform.translate(
                    offset: const Offset(0, _tagHeight / 2),
                    child: Opacity(
                      opacity: isAnimating.value ? 1.0 : 0.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                        child: ColoredBox(
                          color: Colors.white,
                          key: containerKey,
                          child: ListenableBuilder(
                            listenable: controller,
                            builder: (context, child) => ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: maxSelectionHeight),
                              child: isAnimating.value
                                  ? SizedBox(
                                      height: retractAnimation.value,
                                      child: OverflowBox(
                                        maxHeight: maxSelectionHeight,
                                        alignment: Alignment.bottomCenter,
                                        child: child,
                                      ),
                                    )
                                  : child,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TagSelectionView(),
                                _TagCreationTile(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: widget.chipBuilder(onTap: close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagCreationTile extends StatelessWidget {
  const _TagCreationTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        children: [
          Text("Add here!"),
          Spacer(),
          Icon(Icons.add, color: Colors.black),
        ],
      ),
      onTap: () {
        print("Add here!");
      },
    );
  }
}

class _TagSelectionView extends StatelessWidget {
  const _TagSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseSingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: _tagHeight / 2),
              for (int i = 0; i < 20; ++i)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text("$i"),
                        const SizedBox(width: 16.0),
                        const Icon(Icons.check, color: Colors.green),
                        const Spacer(),
                      ],
                    ),
                    onTap: () {
                      print("$i");
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveOverlayNotification extends Notification {
  const _RemoveOverlayNotification();
}

/// Represents a simple removable tag.
class _TagWidget extends StatelessWidget {
  const _TagWidget({
    required this.tag,
    super.key,
  });

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    var data = TagData.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SizedBox(
        height: _tagHeight,
        child: Material(
          color: tag.color,
          child: InkWell(
            onTap: () {
              data.removeTag(tag);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tag.name, style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 16.0),
                  const Icon(Icons.close, size: _tagIconSize, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
