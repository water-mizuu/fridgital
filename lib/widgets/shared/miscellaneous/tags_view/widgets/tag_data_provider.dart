import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/hooks/use_tag_data_future.dart";
import "package:functional_widget_annotation/functional_widget_annotation.dart";
import "package:provider/provider.dart";

part "tag_data_provider.g.dart";

@hwidget
Widget tagDataProvider({required Widget Function(BuildContext, TagData) builder}) {
  // ignore: discarded_futures
  var tagDataFuture = useTagDataFuture();

  return FutureProvider.value(
    initialData: TagData.empty(),
    value: tagDataFuture,
    builder: (context, child) => switch (context.watch<TagData>()) {
      var data => ChangeNotifierProvider.value(
          value: data,
          child: builder(context, data),
        )
    },
  );
}
