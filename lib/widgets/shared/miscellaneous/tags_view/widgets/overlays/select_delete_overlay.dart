import "package:adaptive_dialog/adaptive_dialog.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/"
    "miscellaneous/base_select_tag_overlay.dart";

class SelectDeleteOverlay extends StatelessWidget {
  const SelectDeleteOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSelectTagOverlay(
      title: "DELETE A TAG",
      isTagRendered: (tag) => true,
      isTagEnabled: (tag) => tag is CustomTag,
      onCancel: () => const CloseOverlayNotification().dispatch(context),
      onTagTap: (tag) async {
        if (tag case Tag() as CustomTag) {
          var answer = await showOkCancelAlertDialog(
            context: context,
            title: "Are you sure you want to delete '${tag.name}'?",
            message: "This action cannot be undone.",
          );

          if (!context.mounted) {
            return;
          }

          if (answer case OkCancelResult.ok) {
            DeleteTag(tag).dispatch(context);
            const SwitchOverlayNotification(mode: OverlayMode.select).dispatch(context);
          }
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
