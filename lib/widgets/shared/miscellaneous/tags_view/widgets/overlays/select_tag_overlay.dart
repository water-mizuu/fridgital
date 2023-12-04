import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/"
    "miscellaneous/base_select_tag_overlay.dart";
import "package:provider/provider.dart";

class SelectTagOverlay extends StatelessWidget {
  const SelectTagOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    var activeTags = context.read<TagData>().activeTags;

    return BaseSelectTagOverlay(
      title: "ADD A TAG",
      isTagRendered: (tag) => !activeTags.contains(tag),
      isTagEnabled: (tag) => true,
      onCancel: () => const CloseOverlayNotification().dispatch(context),
      onTagTap: (tag) => SelectedTagOverlayNotification(tag).dispatch(context),
      bottomButtons: [
        IconWidget(
          color: TagColors.addButton,
          icon: Icons.add,
          onTap: () {
            const SwitchOverlayNotification(mode: OverlayMode.add).dispatch(context);
          },
        ),
        IconWidget(
          color: TagColors.addButton,
          icon: Icons.edit,
          onTap: () {
            const SwitchOverlayNotification(mode: OverlayMode.selectEdit).dispatch(context);
          },
        ),
        IconWidget(
          color: const Color(0x7f85100D),
          icon: Icons.delete_outline,
          onTap: () {
            const SwitchOverlayNotification(mode: OverlayMode.selectDelete).dispatch(context);
          },
        ),
      ],
    );
  }
}
