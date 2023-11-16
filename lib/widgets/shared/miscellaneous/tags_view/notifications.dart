import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";

sealed class OverlayNotification extends Notification {
  const OverlayNotification();
}

class SwitchToSelectOverlayNotification extends OverlayNotification {
  const SwitchToSelectOverlayNotification();
}

class SwitchToAddOverlayNotification extends OverlayNotification {
  const SwitchToAddOverlayNotification();
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
