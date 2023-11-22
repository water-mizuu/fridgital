import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";

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
  final TagColor color;
}

class SelectedTagOverlayNotification extends OverlayNotification {
  const SelectedTagOverlayNotification(this.tag);

  final Tag tag;
}

class CloseOverlayNotification extends OverlayNotification {
  const CloseOverlayNotification();
}

class ModifyWorkingTagNotification extends OverlayNotification {
  const ModifyWorkingTagNotification({required this.name, required this.color});

  final String name;
  final TagColor color;
}

class ChooseWorkingTag extends OverlayNotification {
  const ChooseWorkingTag(this.tag);

  final CustomTag tag;
}

class DeleteTag extends OverlayNotification {
  const DeleteTag(this.tag);

  final CustomTag tag;
}
