// TODO(water-mizuu): Refactor this whole file.

import "package:flutter/material.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tags_view.dart";

/// Represents a simple removable tag that is composed of only an icon.
class IconWidget extends StatelessWidget {
  const IconWidget({required this.color, required this.icon, super.key, this.onTap});

  final Color color;
  final IconData? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: ClickableWidget(
        onTap: onTap,
        child: Container(
          color: color,
          height: tagHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(icon, size: tagIconSize, color: Colors.white),
        ),
      ),
    );
  }
}
