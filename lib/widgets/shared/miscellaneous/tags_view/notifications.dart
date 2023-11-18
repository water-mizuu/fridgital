import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/tags_view.dart";

sealed class OverlayNotification extends Notification {
  const OverlayNotification();
}

class SwitchOverlayNotification extends OverlayNotification {
  const SwitchOverlayNotification({required this.mode});

  final OverlayMode mode;
}

class CreateNewTagOverlayNotification extends OverlayNotification {
  const CreateNewTagOverlayNotification({required this.name, required this.color});

  final String name;
  final UserSelectableColor color;
}

class SelectedTagOverlayNotification extends OverlayNotification {
  const SelectedTagOverlayNotification(this.tag);

  final Tag tag;
}

class CloseOverlayNotification extends OverlayNotification {
  const CloseOverlayNotification();
}
