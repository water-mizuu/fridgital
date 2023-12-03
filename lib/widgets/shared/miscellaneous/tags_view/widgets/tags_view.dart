
import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/tag_selector.dart";
import "package:provider/provider.dart";

const tagIconSize = 14.0;
const tagHeight = 32.0;
const tagGapToIcon = 16.0;

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    var tagData = context.watch<TagData>();

    return Wrap(
      runSpacing: 8.0,
      children: [
        for (var tag in tagData.activeTags)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: TagWidget(
              tag: tag,
              onTap: () {
                tagData.removeTag(tag);
              },
            ),
          ),
        const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: TagSelector(),
        ),
      ],
    );
  }
}
