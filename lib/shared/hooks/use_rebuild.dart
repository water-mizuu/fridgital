import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Returns a function that rebuilds the widget the hook is used in.
///
/// This is useful for when you want to rebuild a widget at will
///   without having to use a [StatefulWidget].
void Function() useRebuild() {
  var state = useState(true);

  return () => state.value ^= true;
}
