import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/icon_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/"
    "miscellaneous/base_select_tag_overlay.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";

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
          var completer = Completer<bool>();
          await showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.w800)),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("You are about to delete: "),
                    TagWidget(tag: tag, icon: null),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      completer.complete(false);
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      completer.complete(true);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

          if (await completer.future) {
            if (!context.mounted) {
              return;
            }

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
