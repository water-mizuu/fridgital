import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/back_end/database/tables/tags.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";

class TagData extends ChangeNotifier {
  TagData(this.addableTags, this.activeTags);
  TagData.empty()
      : addableTags = {},
        activeTags = {};

  static const Set<BuiltInTag> _builtInTags = {BuiltInTag.essential};

  static Future<TagData> emptyFromDatabase() async {
    var addableTags = <Tag>{..._builtInTags};
    var activeTags = <Tag>{};

    var loadedAddable = await CustomTagsTable.instance.fetchAddableTags();
    addableTags.addAll(loadedAddable);

    return TagData(addableTags, activeTags);
  }

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

  Future<void> replaceAddableTag(CustomTag target, CustomTag tag) async {
    if (addableTags.remove(target)) {
      addableTags.add(tag);
      await CustomTagsTable.instance.replaceAddableTag(target, tag);
      notifyListeners();
    }
  }

  Future<void> addAddableTag(CustomTag tag) async {
    if (addableTags.add(tag)) {
      await CustomTagsTable.instance.addAddableTag(tag);
      notifyListeners();
    }
  }

  Future<void> removeAddableTag(CustomTag tag) async {
    if (addableTags.remove(tag)) {
      await CustomTagsTable.instance.removeAddableTag(tag);
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
