import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";

/// A mixin that provides a [productDataFuture] that is initialized to an empty
///   [ProductData] object which is loaded from the database.
mixin ProductDataMixin<T extends StatefulWidget> on State<T> {
  @nonVirtual
  late final Future<ProductData> productDataFuture;

  @override
  void initState() {
    super.initState();

    unawaited(productDataFuture = ProductData.fromDatabase());
  }

  @override
  void dispose() {
    unawaited(productDataFuture.then((tagData) => tagData.dispose()));

    super.dispose();
  }
}
