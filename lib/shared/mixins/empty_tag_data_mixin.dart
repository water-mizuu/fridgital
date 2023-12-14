import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";

int count = 0;

/// A mixin that provides a [tagDataFuture] that is initialized to an empty
///   [TagData] object which is loaded from the database.
mixin EmptyTagDataMixin<T extends StatefulWidget> on State<T> {
  @nonVirtual
  late final Future<TagData> tagDataFuture;

  @override
  void initState() {
    super.initState();

    unawaited(tagDataFuture = TagData.loadFromDatabase());
  }

  @override
  void dispose() {
    unawaited(tagDataFuture.then((tagData) => tagData.dispose()));

    super.dispose();
  }
}
