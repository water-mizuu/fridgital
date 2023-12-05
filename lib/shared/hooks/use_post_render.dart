import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Calls [callback] after the widget is rendered.
void usePostRender(FutureOr<void> Function() callback) {
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => callback());
  });
}
