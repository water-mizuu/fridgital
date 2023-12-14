import "dart:async";

import "package:flutter/material.dart";
import "package:fridgital/back_end/database/tables/values/built_in_tags.dart";
import "package:fridgital/back_end/database/tables/values/custom_tags.dart";
import "package:fridgital/shared/classes/immutable_list.dart";
import "package:fridgital/shared/classes/selected_color.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/mixins/record_equatable.dart";

class TagData extends ChangeNotifier {
  TagData(this._addableTags, this._activeTags, {this.onAdd, this.onRemove});
  TagData.empty({this.onAdd, this.onRemove})
      : _addableTags = [],
        _activeTags = [];

  static Future<TagData> loadFromDatabase({
    List<Tag>? initialActiveTags,
    void Function(Tag)? onAdd,
    void Function(Tag)? onRemove,
  }) async {
    var addableTags = <Tag>[];
    var activeTags = initialActiveTags ?? [];

    var [loadedBuiltInTags, loadedCustomTags] = await Future.wait([
      BuiltInTagsTable.instance.fetchAddableBuiltInTags() as Future<List<Tag>>,
      CustomTagsTable.instance.fetchAddableCustomTags(),
    ]);
    addableTags.addAll([...loadedBuiltInTags, ...loadedCustomTags]);

    return TagData(addableTags, activeTags, onAdd: onAdd, onRemove: onRemove);
  }

  /// These are the tags that can be added.
  final List<Tag> _addableTags;

  ImmutableList<Tag> get addableTags => ImmutableList.copyFrom(_addableTags);

  /// These are the tags that are currently active.
  final List<Tag> _activeTags;

  ImmutableList<Tag> get activeTags => ImmutableList.copyFrom(_activeTags);

  final void Function(Tag)? onAdd;
  final void Function(Tag)? onRemove;

  void addTag(Tag tag) {
    if (!_activeTags.contains(tag)) {
      _activeTags.add(tag);
      onAdd?.call(tag);
      notifyListeners();
    }
  }

  void removeTag(Tag tag) {
    if (_activeTags.remove(tag)) {
      onRemove?.call(tag);
      notifyListeners();
    }
  }

  Future<void> replaceAddableTag(CustomTag target, CustomTag tag) async {
    if (_addableTags.indexWhere((tag) => tag is CustomTag && tag.id == target.id) case >= 0 && var addableIndex) {
      _addableTags[addableIndex] = tag;
      if (_activeTags.indexWhere((tag) => tag is CustomTag && tag.id == target.id) case >= 0 && var activeIndex) {
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
  /// Represents the id of the tag in the database.
  int get id;

  /// Represents the name of the tag.
  String get name;

  /// Represents the color of the tag.
  Color get color;
}

class BuiltInTag with RecordEquatable implements Tag {
  const BuiltInTag(this.name, this.color);

  static const List<BuiltInTag> values = [essential];
  static const BuiltInTag essential = BuiltInTag("essentials", TagColors.essential);

  @override
  Never get id => throw UnsupportedError("[BuiltInTag]s should not have its id accessed. This is likely a logic error.");

  @override
  final String name;

  @override
  final Color color;

  @override
  (String, Color) get record => (name, color);
}

class CustomTag with RecordEquatable implements Tag {
  const CustomTag(this.id, this.name, this.color);

  @override
  final int id;

  @override
  final String name;

  @override
  final TagColor color;

  @override
  Record get record => (name, color);
}
