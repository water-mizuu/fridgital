import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/shared/classes/reference.dart";

/// Returns a [Reference] to the given [object], without binding rebuilds to it.
Reference<T> useReference<T>(T object) {
  var state = useMemoized(() => Reference(object), [object]);

  return state;
}
