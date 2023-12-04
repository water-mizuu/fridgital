import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

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

  useState(() {
    // ignore: discarded_futures
    WidgetsBinding.instance.endOfFrame.whenComplete(() {
      focusNode.requestFocus();
    });
  });

  return focusNode;
}