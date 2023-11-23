import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/back_end/database/tables/values/built_in_tags.dart";
import "package:fridgital/back_end/database/tables/values/custom_tags.dart";
import "package:fridgital/shared/classes/immutable_list.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/record_equatable.dart";

class TagData extends ChangeNotifier {
  TagData(this._addableTags, this._activeTags);
  TagData.empty()
      : _addableTags = [],
        _activeTags = [];

  static Future<TagData> emptyFromDatabase() async {
    var addableTags = <Tag>[];
    var activeTags = <Tag>[];

    var [loadedBuiltInTags, loadedCustomTags] = await Future.wait([
      BuiltInTagsTable.instance.fetchAddableBuiltInTags(),
      CustomTagsTable.instance.fetchAddableCustomTags(),
    ]);
    addableTags.addAll([...loadedBuiltInTags, ...loadedCustomTags]);

    return TagData(addableTags, activeTags);
  }

  /// These are the tags that can be added.
  final List<Tag> _addableTags;

  ImmutableList<Tag> get addableTags => ImmutableList(_addableTags);

  /// These are the tags that are currently active.
  final List<Tag> _activeTags;

  ImmutableList<Tag> get activeTags => ImmutableList(_activeTags);

  void addTag(Tag tag) {
    if (!_activeTags.contains(tag)) {
      _activeTags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(Tag tag) {
    if (_activeTags.remove(tag)) {
      notifyListeners();
    }
  }

  Future<void> replaceAddableTag(CustomTag target, CustomTag tag) async {
    if (_addableTags.indexOf(target) case >= 0 && var addableIndex) {
      _addableTags[addableIndex] = tag;
      if (_activeTags.indexOf(target) case >= 0 && var activeIndex) {
        _activeTags[activeIndex] = tag;
      }

      await CustomTagsTable.instance.replaceAddableTag(target, tag);
      notifyListeners();
    }
  }

  Future<void> addAddableTag({required String name, required TagColor color}) async {
    if (!_addableTags.any((tag) => tag.name == name)) {
      var tag = await CustomTagsTable.instance.addAddableTag(name: name, color: color);
      _addableTags.add(tag);
      notifyListeners();
    }
  }

  Future<void> removeAddableTag(CustomTag tag) async {
    if (_addableTags.remove(tag)) {
      await CustomTagsTable.instance.removeAddableTag(tag.id);
      _activeTags.remove(tag);
      notifyListeners();
    }
  }
}

sealed class Tag {
  int get id;
  String get name;
  Color get color;
}

class BuiltInTag implements Tag {
  const BuiltInTag(this.name, this.color);

  static const List<BuiltInTag> values = [essential];
  static const BuiltInTag essential = BuiltInTag("essentials", TagColors.essential);

  @override
  int get id => throw UnsupportedError("[BuiltInTag]s should not have its id accessed. This is likely a logic error.");

  @override
  final String name;

  @override
  final Color color;

  Record get record => (name, color);
}

class CustomTag with RecordEquatable implements Tag {
  const CustomTag(this.id, this.name, this.color);

  /// Represents the id of the tag in the database.
  @override
  final int id;

  @override
  final String name;

  @override
  final TagColor color;

  @override
  Record get record => (name, color);
}
