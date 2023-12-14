import "dart:async";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/hooks/use_dispose.dart";

/// Returns a [Future] that resolves to an empty [TagData] object.
Future<TagData> useTagDataFuture({
  List<Tag>? initialTags,
  void Function(Tag)? onAdd,
  void Function(Tag)? onRemove,
}) {
  var future = useMemoized(
    () => TagData.loadFromDatabase(
      initialActiveTags: initialTags,
      onAdd: onAdd,
      onRemove: onRemove,
    ),
  );

  useDispose(() {
    future.then((v) => v.dispose());
  });

  return future;
}
