import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/shared/hooks/use_init.dart";

/// Calls [callback] after the widget is rendered.
void usePostRender(FutureOr<void> Function() callback) {
  useInit(() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => await callback());
  });
}

void Function() usePostRenderCallback(FutureOr<void> Function() callback, [List<Object?> keys = const <Object?>[]]) {
  return useCallback(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) async => await callback());
    },
    keys,
  );
}
