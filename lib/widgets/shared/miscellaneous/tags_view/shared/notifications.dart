import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/enums/overlay_mode.dart";

sealed class TagOverlayNotification extends Notification {
  const TagOverlayNotification();
}

class SwitchOverlayNotification extends TagOverlayNotification {
  const SwitchOverlayNotification({required this.mode});

  final OverlayMode mode;
}

class CreateNewTagOverlayNotification extends TagOverlayNotification {
  const CreateNewTagOverlayNotification({required this.name, required this.color});

  final String name;
  final TagColor color;
}

class SelectedTagOverlayNotification extends TagOverlayNotification {
  const SelectedTagOverlayNotification(this.tag);

  final Tag tag;
}

class CloseOverlayNotification extends TagOverlayNotification {
  const CloseOverlayNotification();
}

class ModifyWorkingTagNotification extends TagOverlayNotification {
  const ModifyWorkingTagNotification({required this.name, required this.color});

  final String name;
  final TagColor color;
}

class ChooseWorkingTagNotification extends TagOverlayNotification {
  const ChooseWorkingTagNotification(this.tag);

  final CustomTag tag;
}

class DeleteTagNotification extends TagOverlayNotification {
  const DeleteTagNotification(this.tag);

  final CustomTag tag;
}
