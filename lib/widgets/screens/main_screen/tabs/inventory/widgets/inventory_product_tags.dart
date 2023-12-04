import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/change_notifiers.dart/product_data.dart";
import "package:fridgital/back_end/change_notifiers.dart/tag_data.dart";
import "package:fridgital/shared/classes/immutable_list.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/find_box.dart";
import "package:fridgital/shared/hooks/use_global_key.dart";
import "package:fridgital/widgets/shared/helper/invisible.dart";
import "package:fridgital/widgets/shared/miscellaneous/tags_view/widgets/shared/tag_widget.dart";

class InventoryProductTags extends HookWidget {
  const InventoryProductTags({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var isExtraShown = useState(false);
    var isComputing = useState(true);

    var extraCounterKey = useGlobalKey();
    var tagContainerKey = useGlobalKey();

    var renderedTags = useState(product.tags);
    var renderedTagKeyPairs = useMemoized(
      () => [for (var tag in renderedTags.value) (tag, GlobalKey())],
      [renderedTags.value],
    );
    var hiddenTags = useMemoized(
      () => product.tags.skip(renderedTags.value.length).toList(),
      [product.tags, renderedTags.value],
    );

    useEffect(() {
      /// We compute for the overflow.

      if (renderedTags.value.isEmpty) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        var containerSize = tagContainerKey.renderBox?.size ?? Size.zero;
        var productsThatCanBeFitted = <Tag>[];

        var accumulativeWidth = switch (extraCounterKey.renderBox?.size.width) {
          var width? => width + 2.0,
          null => 0.0,
        };

        for (var (index, (tag, key)) in renderedTagKeyPairs.indexed) {
          var size = key.renderBox?.size ?? Size.zero;
          var addedWidth = 2.0 + size.width;

          if (size == Size.zero || accumulativeWidth + addedWidth >= containerSize.width) {
            break;
          }

          productsThatCanBeFitted.add(tag);
          accumulativeWidth += size.width;
          accumulativeWidth += index > 0 ? 2.0 : 0.0; // Account for the spacing between the tags.
        }

        /// Since it overflows, we need to do some extra work.
        isExtraShown.value = productsThatCanBeFitted.length < product.tags.length;
        renderedTags.value = ImmutableList.copyFrom([for (var tag in productsThatCanBeFitted) tag]);
        isComputing.value = false;
      });
    });

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        SizedBox(
          height: 24.0,
          child: OverflowBox(
            key: tagContainerKey,
            child: Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: isComputing.value ? 0.0 : 1.0,
                child: Wrap(
                  clipBehavior: Clip.hardEdge,
                  spacing: 2.0,
                  children: [
                    for (var (tag, key) in renderedTagKeyPairs)
                      SizedBox(
                        key: key,
                        height: 24.0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TagWidget(tag: tag, icon: null),
                        ),
                      ),

                    /// We only show this extra counter if the status is [ProductTabsRender.rendering].
                    if (isExtraShown.value)
                      SizedBox(
                        height: 24.0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TagWidget(
                            tag: CustomTag(-1, "+ ${hiddenTags.length}", TagColors.selectable[0]),
                            icon: null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isComputing.value)
          Invisible(
            child: SizedBox(
              key: extraCounterKey,
              height: 24.0,
              child: FittedBox(
                child: TagWidget(
                  tag: CustomTag(-1, "+ 1", TagColors.selectable[0]),
                  icon: null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
