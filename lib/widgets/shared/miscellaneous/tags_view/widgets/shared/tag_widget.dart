import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/extensions/color_conversion.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";

/// Represents a simple removable tag that is composed of text with an optional icon.
class TagWidget extends StatelessWidget {
  const TagWidget({required this.tag, super.key, this.icon = Icons.close, this.onTap, this.enabled = true});

  final Tag tag;
  final IconData? icon;
  final void Function()? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    var backgroundColor = enabled ? tag.color : tag.color.desaturate(0.65);
    var textColor = enabled ? Colors.white : Colors.white.dim(0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onTap: enabled ? onTap : () => (),
        child: SizedBox(
          height: tagHeight,
          child: Material(
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: icon == null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(tag.name, style: TextStyle(color: textColor))],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.name, style: TextStyle(color: textColor)),
                        const SizedBox(width: tagGapToIcon),
                        Icon(icon, size: tagIconSize, color: textColor),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
