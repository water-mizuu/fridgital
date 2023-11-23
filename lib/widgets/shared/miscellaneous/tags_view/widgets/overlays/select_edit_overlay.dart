import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/"
    "miscellaneous/base_select_tag_overlay.dart";

class SelectEditOverlay extends StatelessWidget {
  const SelectEditOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSelectTagOverlay(
      title: "EDIT A TAG",
      isTagRendered: (tag) => true,
      isTagEnabled: (tag) => tag is CustomTag,
      onCancel: () => const CloseOverlayNotification().dispatch(context),
      onTagTap: (tag) async {
        assert(tag is CustomTag, "This method should only be called when a custom tag is tapped!");
        if (tag case Tag() as CustomTag) {
          ChooseWorkingTagNotification(tag).dispatch(context);
          const SwitchOverlayNotification(mode: OverlayMode.edit).dispatch(context);
        }
      },
      bottomButtons: [
        IconWidget(
          icon: Icons.arrow_back,
          color: TagColors.addButton,
          onTap: () {
            const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
          },
        ),
      ],
    );
  }
}
