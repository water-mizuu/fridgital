import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";

class InheritedTagData extends InheritedWidget {
  const InheritedTagData({required this.tagData, required super.child, super.key});

  final TagData tagData;

  @override
  bool updateShouldNotify(InheritedTagData oldWidget) {
    return tagData != oldWidget.tagData;
  }
}
