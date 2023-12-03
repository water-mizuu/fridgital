import "dart:math" as math;

import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/utils.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

final class BaseSelectTagOverlay extends StatefulWidget {
  const BaseSelectTagOverlay({
    required this.title,
    required this.isTagRendered,
    required this.isTagEnabled,
    required this.onCancel,
    required this.onTagTap,
    required this.bottomButtons,
    super.key,
  });

  final String title;
  final bool Function(Tag tag) isTagRendered;
  final bool Function(Tag tag) isTagEnabled;

  final void Function() onCancel;
  final void Function(Tag tag) onTagTap;
  final List<Widget> bottomButtons;

  @override
  State<BaseSelectTagOverlay> createState() => _BaseSelectTagOverlayState();
}

class _BaseSelectTagOverlayState extends State<BaseSelectTagOverlay> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var addableTags = context.select((TagData data) => data.addableTags).toList();
    var isTextEmpty = textEditingController.text == "";
    var distances = [
      for (var tag in addableTags) //
        if (isTextEmpty) 0 else levenshtein(tag.name, textEditingController.text),
    ];
    var threshold = distances.map((d) => d + distances.length).fold(intMax, math.min);
    var indices = List<int>.generate(distances.length, (i) => i) //
      ..sort((a, b) => isTextEmpty ? 0 : distances[a].compareTo(distances[b]))
      ..removeWhere((i) => distances[i] > threshold);

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
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClickableWidget(
                        onTap: widget.onCancel,
                        child: const Icon(Icons.close),
                      ),
                    ),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 284.0),
                child: MouseSingleChildScrollView(
                  child: Wrap(
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var index in indices)
                        if (addableTags[index] case var tag when widget.isTagRendered(tag))
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: TagWidget(
                              tag: tag,
                              icon: null,
                              onTap: () => widget.onTagTap(tag),
                              enabled: widget.isTagEnabled(tag),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            /// Search field.

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search for a tag",
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Material Icons",
                  ),
                ),
                controller: textEditingController,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var (i, button) in widget.bottomButtons.indexed) ...[
                  if (i > 0) const SizedBox(width: 8.0),
                  button,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
