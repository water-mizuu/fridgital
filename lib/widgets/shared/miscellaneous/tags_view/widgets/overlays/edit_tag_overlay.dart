import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/miscellaneous/"
    "modifiable_tag_form_overlay.dart";

class EditTagOverlay extends StatelessWidget {
  const EditTagOverlay({required this.tag, super.key});

  final CustomTag tag;

  @override
  Widget build(BuildContext context) {
    return ModifiableTagFormOverlay(
      initialText: tag.name,
      initialColor: tag.color,
      onCancel: () => const CloseOverlayNotification().dispatch(context),
      onSubmit: (name, color) {
        ModifyWorkingTagNotification(name: name, color: color).dispatch(context);
      },
      confirmationTag: const CustomTag(-1, "Save", TagColors.addButton),
      confirmationIcon: Icons.check,
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
