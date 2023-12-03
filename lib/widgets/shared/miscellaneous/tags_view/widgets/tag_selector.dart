
import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/overlay_holder.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";
import "package:provider/provider.dart";

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  void Function() tapHandler(BuildContext context) {
    return () {
      if (!context.mounted) {
        return;
      }

      OverlayEntry? entry;

      entry = OverlayEntry(
        maintainState: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<TagData>(),
          child: NotificationListener<CloseOverlayNotification>(
            onNotification: (notification) {
              entry?.remove();
              return true;
            },
            child: const OverlayHolder(),
          ),
        ),
      );

      Overlay.of(context).insert(entry);
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        onTap: tapHandler(context),
        child: Container(
          height: tagHeight,
          color: TagColors.selector,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const IgnorePointer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("filter", style: TextStyle(color: Colors.white)),
                SizedBox(width: tagGapToIcon),
                Icon(Icons.add, size: tagIconSize, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
