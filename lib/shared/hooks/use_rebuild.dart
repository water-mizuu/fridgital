import "package:flutter_hooks/flutter_hooks.dart";

void Function() useRebuild() {
  var state = useState(true);

  return () => state.value ^= true;
}
