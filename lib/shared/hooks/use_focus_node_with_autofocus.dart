import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/shared/hooks/use_post_render.dart";

FocusNode useFocusNodeWithAutoFocus({
  String? debugLabel,
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
