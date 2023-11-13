import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/helper/change_notifier_builder.dart";
import "package:mouse_scroll/mouse_scroll.dart";

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
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.loose(Size(constraints.maxWidth / 2, constraints.maxHeight)),
                    child: const TagSelector(),
                  ),
                ),
                for (var tag in tagData.tags)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: TagWidget(tag: tag),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

const double tagHeight = 32.0;

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> with TickerProviderStateMixin {
  Widget selectionChip({void Function()? onTap, Color? color}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: SizedBox(
            width: constraints.maxWidth,
            height: tagHeight,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Filter", style: TextStyle(color: Colors.white)),
                            Icon(Icons.expand_more, color: Colors.white),
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
        var renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox?.localToGlobal(Offset.zero) case Offset left) {
          var controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
          var retractAnimation = const AlwaysStoppedAnimation(0.0) as Animation<double>;

          var isAnimating = ValueNotifier(false);

          var key = GlobalKey();
          var width = renderBox!.size.width;

          late OverlayEntry entry;
          entry = OverlayEntry(
            maintainState: true,
            builder: (context) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Transform.translate(
                  offset: left,
                  child: Stack(
                    children: [
                      ListenableBuilder(
                        listenable: isAnimating,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: const Offset(0, tagHeight / 2),
                            child: Opacity(
                              opacity: isAnimating.value ? 1.0 : 0.0,
                              child: Container(
                                key: key,
                                padding: const EdgeInsets.all(8),
                                width: width,
                                color: Colors.white,
                                child: ListenableBuilder(
                                  listenable: controller,
                                  builder: (context, child) {
                                    return ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      child: SizedBox(
                                        height: isAnimating.value ? retractAnimation.value : null,
                                        child: MouseSingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: tagHeight / 2),
                                              ListTile(
                                                title: const Text("A"),
                                                onTap: () {
                                                  print("A");
                                                },
                                              ),
                                              ListTile(
                                                title: const Text("A"),
                                                onTap: () {
                                                  print("B");
                                                },
                                              ),
                                              ListTile(
                                                title: const Text("A"),
                                                onTap: () {
                                                  print("C");
                                                },
                                              ),
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
                      ),
                      SizedBox(
                        width: width,
                        child: selectionChip(
                          onTap: () async {
                            await controller.reverse();
                            entry.remove();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          Overlay.of(context).insert(entry);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if ((key.currentContext?.findRenderObject() as RenderBox?)?.size.height case double target) {
              retractAnimation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn) //
                  .drive(Tween(begin: 0.0, end: target));
              isAnimating.value = true;
            }

            controller.forward();
          });
        }
      },
    );
  }
}

/// Represents a simple removable tag.
class TagWidget extends StatelessWidget {
  const TagWidget({
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
        height: tagHeight,
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
                  const Icon(Icons.close, size: 14.0, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
