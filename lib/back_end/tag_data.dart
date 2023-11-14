import "package:flutter/material.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/inherited_widgets/inherited_tag_data.dart";

class TagData extends ChangeNotifier {
  TagData(this.tags);
  TagData.empty() : tags = {};

  static TagData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedTagData>()?.tagData;
  }

  static TagData of(BuildContext context) {
    return maybeOf(context)!;
  }

  final Set<Tag> tags;

  void addTag(Tag tag) {
    if (tags.add(tag)) {
      notifyListeners();
    }
  }

  void removeTag(Tag tag) {
    if (tags.remove(tag)) {
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
