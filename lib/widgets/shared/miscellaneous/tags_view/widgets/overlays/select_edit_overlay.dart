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

class SelectEditOverlay extends StatelessWidget {
  const SelectEditOverlay({super.key});

  void Function() tapHandler(BuildContext context, Tag tag) {
    return () {
      if (tag case _ as CustomTag) {
        ChooseWorkingTag(tag).dispatch(context);
        const SwitchOverlayNotification(mode: OverlayMode.edit).dispatch(context);
      }
    };
  }

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
                      onTap: () => const CloseOverlayNotification().dispatch(context),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Text(
                    "EDIT A TAG",
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
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: TagWidget(
                            tag: tag,
                            icon: null,
                            onTap: tapHandler(context, tag),
                            enabled: tag is CustomTag,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            IconWidget(
              icon: Icons.arrow_back,
              color: TagColors.addButton,
              onTap: () {
                const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
