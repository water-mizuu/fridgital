import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

final class BaseSelectTagOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var addableTags = context.read<TagData>().addableTags;

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
                      onTap: () => onCancel(),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
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
                      for (var tag in addableTags)
                        if (isTagRendered(tag))
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: TagWidget(
                              tag: tag,
                              icon: null,
                              onTap: () => onTagTap(tag),
                              enabled: isTagEnabled(tag),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var (i, button) in bottomButtons.indexed) ...[
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
