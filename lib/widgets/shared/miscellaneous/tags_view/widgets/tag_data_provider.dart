import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/hooks/use_tag_data_future.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/shared/notifications.dart";
import "package:provider/provider.dart";

class TagDataProvider extends HookWidget {
  const TagDataProvider({
    required this.builder,
    this.onTagRemove,
    this.onTagAdd,
    List<Tag>? initialTags,
    super.key,
  }) : initialTags = initialTags ?? const <Tag>[];

  final void Function(Tag)? onTagRemove;
  final void Function(Tag)? onTagAdd;
  final Widget Function(BuildContext, TagData) builder;
  final List<Tag> initialTags;

  @override
  Widget build(BuildContext context) {
    // ignore: discarded_futures
    var tagDataFuture = useTagDataFuture(initialTags: initialTags.toList(), onAdd: onTagAdd, onRemove: onTagRemove);

    return NotificationListener<TagOverlayNotification>(
      onNotification: (notification) {
        if (kDebugMode) {
          print("The notification is ${notification.runtimeType}");
        }
        return false;
      },
      child: FutureProvider.value(
        initialData: TagData.empty(),
        value: tagDataFuture,
        builder: (context, child) => switch (context.watch<TagData>()) {
          var data => ChangeNotifierProvider.value(
              value: data,
              child: builder(context, data),
            )
        },
      ),
    );
  }
}
