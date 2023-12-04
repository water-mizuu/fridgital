import "dart:async";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";

/// Returns a [Future] that resolves to an empty [TagData] object.
Future<TagData> useTagDataFuture() {
  var future = useMemoized(TagData.emptyFromDatabase);

  useEffect(() => () => unawaited(future.then((t) => t.dispose())));

  return future;
}
