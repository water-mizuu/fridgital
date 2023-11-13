import "package:flutter/material.dart";
import "package:fridgital/widgets/inherited_widgets/inherited_tag_data.dart";

class TagData extends ChangeNotifier {
  TagData(this.tags);
  TagData.empty() : tags = [];

  static TagData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedTagData>()?.tagData;
  }

  static TagData of(BuildContext context) {
    return maybeOf(context)!;
  }

  final List<Tag> tags;
}

sealed class Tag {
  String get name;
}

final class BuiltInTag implements Tag {
  const BuiltInTag._(this.name);

  static const BuiltInTag essential = BuiltInTag._("essentials");

  @override
  final String name;
}

final class CustomTag implements Tag {
  const CustomTag(this.name);

  @override
  final String name;
}
