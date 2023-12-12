import "package:flutter_hooks/flutter_hooks.dart";

/// Runs the given [callback] once, when the widget is first built.
void useInit(void Function() callback) {
  useEffect(
    () {
      callback();
    },
    const [],
  );
}
