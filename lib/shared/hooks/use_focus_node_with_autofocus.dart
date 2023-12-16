import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/shared/hooks/use_post_render.dart";

/// Returns a [FocusNode] that requests focus when the widget is first built.
FocusNode useFocusNodeWithAutoFocus({
  String? debugLabel,
  // ignore: deprecated_member_use
  FocusOnKeyCallback? onKey,
  FocusOnKeyEventCallback? onKeyEvent,
  bool skipTraversal = false,
  bool canRequestFocus = true,
  bool descendantsAreFocusable = true,
}) {
  var focusNode = useFocusNode(
    debugLabel: debugLabel,
    onKey: onKey,
    onKeyEvent: onKeyEvent,
    skipTraversal: skipTraversal,
    canRequestFocus: canRequestFocus,
    descendantsAreFocusable: descendantsAreFocusable,
  );

  usePostRender(() {
    focusNode.requestFocus();
  });

  return focusNode;
}
