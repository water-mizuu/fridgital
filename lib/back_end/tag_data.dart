import "package:flutter/material.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";

class TagData extends ChangeNotifier {
  TagData(this.addableTags, this.activeTags);
  TagData.empty()
      : addableTags = {},
        activeTags = {};

  /// These are the tags that can be added.
  final Set<Tag> addableTags;

  /// These are the tags that are currently active.
  final Set<Tag> activeTags;

  void addTag(Tag tag) {
    if (activeTags.add(tag)) {
      notifyListeners();
    }
  }

  void removeTag(Tag tag) {
    if (activeTags.remove(tag)) {
      notifyListeners();
    }
  }
}

sealed class Tag {
  String get name;
  Color get color;
}

final class BuiltInTag implements Tag {
  const BuiltInTag._(this.name, this.color);

  static const BuiltInTag essential = BuiltInTag._("essentials", TagColors.essential);

  @override
  final String name;

  @override
  final Color color;
}

final class CustomTag implements Tag {
  const CustomTag(this.name, this.color);

  @override
  final String name;

  @override
  final UserSelectableColor color;
}
