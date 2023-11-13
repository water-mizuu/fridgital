import "package:flutter/material.dart";
import "package:fridgital/back_end/tag_data.dart";

class TagsView extends StatefulWidget {
  const TagsView({super.key});

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  late final TagData tagData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    tagData = TagData.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print(constraints.maxWidth);
        return Wrap(
          children: [
            SizedBox(
              width: constraints.maxWidth / 2,
              child: const TagSelector(),
            ),
            for (var tag in tagData.tags)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Chip(
                  label: Text(tag.name),
                ),
              ),
          ],
        );
      },
    );
  }
}

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.green,
      child: RawChip(
        label: const Text("+ Tag"),
        onPressed: () {
          print("Hi");
        },
      ),
    );
  }
}
