import "package:flutter/material.dart";
import "package:fridgital/shared/hooks/use_init.dart";

/// Calls [callback] after the widget is rendered.
void usePostRender(void Function() callback) {
  useInit(() {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  });
}
