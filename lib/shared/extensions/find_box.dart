import "package:flutter/material.dart";

extension FindBoxExtension on GlobalKey {
  RenderBox? get renderBox => currentContext?.findRenderObject() as RenderBox?;
}

extension OffsetFromExtension on RenderBox {
  Offset get offset => localToGlobal(Offset.zero);
  Offset offsetFrom(RenderBox parent) => localToGlobal(Offset.zero, ancestor: parent);
}
