import "package:flutter_hooks/flutter_hooks.dart";

void useInit(void Function() callback, [List<Object?>? keys]) {
  useEffect(
    () {
      callback();
    },
    keys ?? const [],
  );
}
