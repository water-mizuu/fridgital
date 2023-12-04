import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/hooks.dart";
import "package:provider/provider.dart";

class TagDataProvider extends HookWidget {
  const TagDataProvider({required this.builder, super.key});

  final Widget Function(BuildContext, TagData) builder;

  @override
  Widget build(BuildContext context) {
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
}
