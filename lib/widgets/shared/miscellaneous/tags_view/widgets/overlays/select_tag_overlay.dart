// TODO(water-mizuu): Refactor this whole file.

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:provider/provider.dart";

class SelectTagOverlay extends StatelessWidget {
  const SelectTagOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var TagData(:activeTags, :addableTags) = context.read();
    var availableTags = addableTags.where((tag) => !activeTags.contains(tag)).toList();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ClickableWidget(
                    onTap: () => const CloseOverlayNotification().dispatch(context),
                    child: const Icon(Icons.close),
                  ),
                ),
                Text(
                  "ADD A TAG",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 284.0),
              child: MouseSingleChildScrollView(
                child: Wrap(
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var tag in availableTags)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: TagWidget(
                          tag: tag,
                          icon: null,
                          onTap: () => SelectedTagOverlayNotification(tag).dispatch(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  color: TagColors.addButton,
                  icon: Icons.add,
                  onTap: () => const SwitchOverlayNotification(mode: OverlayMode.add).dispatch(context),
                ),
                const SizedBox(height: 8.0, width: 8.0),
                IconWidget(
                  color: TagColors.addButton,
                  icon: Icons.edit,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.selectEdit).dispatch(context);
                  },
                ),
                const SizedBox(height: 8.0, width: 8.0),
                IconWidget(
                  color: const Color(0x7f85100D),
                  icon: Icons.delete_outline,
                  onTap: () {
                    const SwitchOverlayNotification(mode: OverlayMode.selectDelete).dispatch(context);
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
