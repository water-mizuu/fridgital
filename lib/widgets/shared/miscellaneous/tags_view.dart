import "dart:ui";

import "package:animations/animations.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/helper/change_notifier_builder.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";

const _tagIconSize = 14.0;
const _tagHeight = 32.0;
const _tagGapToIcon = 16.0;

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      changeNotifier: TagData.of(context),
      builder: (context, tagData, child) {
        return Wrap(
          runSpacing: 8.0,
          children: [
            for (var tag in tagData.tags)
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
      },
    );
  }
}

class TagSelector extends StatelessWidget {
  const TagSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: ClickableWidget(
            onTap: () {
              if (!context.mounted) {
                return;
              }

              var tagData = TagData.of(context);
              var allTags = tagData.availableTags;
              var addedTags = tagData.tags;
              var availableTags = allTags.difference(addedTags);

              late OverlayEntry entry;
              entry = OverlayEntry(
                maintainState: true,
                builder: (_) => OverlayWidget(
                  width: constraints.maxWidth * 0.9,
                  availableTags: availableTags,
                  close: () {
                    entry.remove();
                  },
                  submit: (tag) {
                    tagData.addTag(tag);
                    entry.remove();
                  },
                ),
              );

              Overlay.of(context).insert(entry);
            },
            child: const SizedBox(
              height: _tagHeight,
              child: Material(
                color: TagColors.selector,
                child: IgnorePointer(
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
      },
    );
  }
}

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({
    required this.width,
    required this.availableTags,
    required this.submit,
    required this.close,
    super.key,
  });

  final double width;
  final Set<Tag> availableTags;

  final void Function(Tag tag) submit;
  final void Function() close;

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> with TickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        animationController.reverse();
        widget.close();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: ColoredBox(
            color: const Color(0xffCCAEBB).withOpacity(0.5),
            child: Center(
              child: FadeScaleTransition(
                animation: animationController,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: widget.width,
                    decoration: const BoxDecoration(
                      color: Color(0xffFFFDF6),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ClickableWidget(
                            onTap: widget.close,
                            child: const Icon(Icons.close),
                          ),
                        ),
                        Text(
                          "SELECT A TAG",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8.0),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 312),
                          child: MouseSingleChildScrollView(
                            child: Wrap(
                              runSpacing: 8.0,
                              children: [
                                for (var tag in widget.availableTags)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: _TagWidget(
                                      tag: tag,
                                      icon: null,
                                      onTap: () async {
                                        await animationController.reverse();
                                        widget.submit(tag);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _TagWidget(
                          tag: CustomTag("Create a new tag", TagColors.selectable.$3),
                          icon: Icons.add,
                          onTap: () {
                            print("Create a new tag");
                          },
                        ),
                      ],
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
