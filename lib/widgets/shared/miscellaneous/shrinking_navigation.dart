import "package:flutter/material.dart";
import "package:fridgital/icons/figma_icon_font.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/normalize_number.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/helper/listenable_animated_widget/listenable_animated_container.dart";
import "package:fridgital/widgets/shared/helper/listenable_animated_widget/listenable_animated_transform.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

class ShrinkingNavigation extends StatefulWidget {
  const ShrinkingNavigation({
    required this.controller,
    required this.latestScrollOffset,
    super.key,
  });

  final TabController controller;
  final ValueNotifier<double> latestScrollOffset;

  @override
  State<ShrinkingNavigation> createState() => _ShrinkingNavigationState();
}

/// I need help. I do not know of a better way to do this.
/// It works, but I have to render three layers of the same widget
/// to compute their offsets and then animate them.
///
/// I need tips.
class _ShrinkingNavigationState extends State<ShrinkingNavigation> with TickerProviderStateMixin {
  ValueNotifier<void>? routePopNotifier;
  bool isRetracted = false;

  void updateRetracted() {
    setState(() {
      isRetracted = widget.latestScrollOffset.value > 0.0;
    });
  }

  void toggleRetracted() {
    setState(() {
      isRetracted = !isRetracted;
    });
  }

  void updateOffsets() {
    if (parentKey.currentContext?.findRenderObject() case RenderBox parentBox when parentBox.hasSize) {
      for (var (i, key) in navigationKeys.indexed) {
        if (key.currentContext?.findRenderObject() case RenderBox box when box.hasSize) {
          navigationOffsets[i] = box.localToGlobal(Offset.zero, ancestor: parentBox) +
              Offset(0.0, box.hasSize ? box.size.height * 1.0625 : 0.0) +
              Offset(box.hasSize ? box.size.width / 2 : 0.0, 0.0) +
              const Offset(-8.0, 0.0);
        }
      }

      /// Compute the difference.
      if (retractedKey.currentContext?.findRenderObject() case RenderBox retractedBox when retractedBox.hasSize) {
        if (expandedKey.currentContext?.findRenderObject() case RenderBox expandedBox when expandedBox.hasSize) {
          retractedOffset = expandedBox.localToGlobal(Offset.zero) - retractedBox.localToGlobal(Offset.zero);
        }
      }

      setState(() => hasComputedOffsets = true);
    }
  }

  @override
  void didUpdateWidget(covariant ShrinkingNavigation oldWidget) {
    if (oldWidget.latestScrollOffset != widget.latestScrollOffset) {
      oldWidget.latestScrollOffset.removeListener(updateRetracted);
      widget.latestScrollOffset.addListener(updateRetracted);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routePopNotifier ??= RouteState.of(context).popNotifier..addListener(updateOffsets);
  }

  @override
  void initState() {
    super.initState();

    widget.latestScrollOffset.addListener(updateRetracted);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateOffsets();
    });
  }

  @override
  void dispose() {
    widget.latestScrollOffset.removeListener(updateRetracted);

    super.dispose();
  }

  bool isAnimating = false;
  bool hasComputedOffsets = false;
  GlobalKey parentKey = GlobalKey();

  GlobalKey retractedKey = GlobalKey();
  GlobalKey expandedKey = GlobalKey();

  Offset retractedOffset = Offset.zero;

  List<Offset> navigationOffsets = List.generate(4, (_) => Offset.zero);
  List<GlobalKey> navigationKeys = List.generate(4, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    const retractDuration = Duration(milliseconds: 125);

    const iconSize = 32.0;
    const margin = 20.0;
    const padding = 8.0;
    const indicator = (width: 16.0, height: 4.0);

    var width = MediaQuery.sizeOf(context).width - margin * 2;
    var arbitraryRetracted = iconSize + padding * 2;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(margin),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              /// Evaluated if the navigation is retracted
              RepaintBoundary(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.00,
                    child: Container(
                      padding: const EdgeInsets.all(padding),
                      width: arbitraryRetracted,
                      child: UnconstrainedBox(
                        constrainedAxis: Axis.vertical,
                        alignment: Alignment.centerRight,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int i = 0; i < 4; ++i) const SizedBox(height: iconSize, width: iconSize),
                              Icon(Icons.menu, size: iconSize, color: FigmaColors.pinkAccent, key: retractedKey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Evaluated if the navigation is not retracted
              RepaintBoundary(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.00,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: padding),
                      width: width,
                      child: UnconstrainedBox(
                        constrainedAxis: Axis.vertical,
                        alignment: Alignment.centerRight,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int i = 0; i < 4; ++i) const SizedBox(height: iconSize, width: iconSize),
                              Icon(null, size: iconSize, key: expandedKey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Actual displayed.
              ListenableAnimatedContainer(
                padding: const EdgeInsets.symmetric(vertical: padding),
                decoration: BoxDecoration(
                  color: FigmaColors.whiteAccent,
                  borderRadius: BorderRadius.circular(256.0),
                ),
                onForward: () {
                  isAnimating = true;
                },
                onEnd: () {
                  isAnimating = false;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!isRetracted) {
                      updateOffsets();
                    }
                  });
                },
                duration: retractDuration,
                width: isRetracted ? arbitraryRetracted : width,
                child: Stack(
                  children: [
                    UnconstrainedBox(
                      key: parentKey,
                      constrainedAxis: Axis.vertical,
                      alignment: Alignment.centerRight,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < 4; ++i)
                              ListenableAnimatedTransform.translate(
                                duration: retractDuration,
                                offset: isRetracted ? -retractedOffset : Offset.zero,
                                curve: Curves.fastOutSlowIn,
                                child: ClickableWidget(
                                  onTap: () {
                                    ShrinkingNavigationUpdateNotification(i).dispatch(context);
                                  },
                                  child: Container(
                                    height: iconSize,
                                    width: iconSize,
                                    color: Colors.transparent,
                                    key: navigationKeys[i],
                                    child: Center(
                                      child: Icon(
                                        const [
                                          FigmaIconFont.book,
                                          FigmaIconFont.fridge,
                                          Icons.home_outlined,
                                          Icons.list_alt_outlined,
                                        ][i],
                                        size: iconSize,
                                        color: FigmaColors.pinkAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ListenableAnimatedTransform.translate(
                              duration: retractDuration,
                              offset: isRetracted ? -retractedOffset : Offset.zero,
                              curve: Curves.fastOutSlowIn,
                              child: ClickableWidget(
                                onTap: toggleRetracted,
                                child: const SizedBox(
                                  width: iconSize,
                                  height: iconSize,
                                  child: Icon(Icons.menu, size: iconSize, color: FigmaColors.pinkAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isAnimating && !isRetracted && hasComputedOffsets)
                      IgnorePointer(
                        child: ListenableBuilder(
                          listenable: widget.controller.animation!,
                          builder: (context, child) {
                            var TabController(:index, :previousIndex, :animation!) = widget.controller;
                            var offset = Offset.lerp(
                              navigationOffsets[previousIndex],
                              navigationOffsets[index],
                              animation.value.normalize(between: previousIndex, and: index),
                            );

                            return offset != null //
                                ? Transform.translate(offset: offset, child: child)
                                : child!;
                          },
                          child: Opacity(
                            opacity: 1.0,
                            child: Container(
                              width: indicator.width,
                              height: indicator.height,
                              decoration: BoxDecoration(
                                color: FigmaColors.pinkAccent,
                                borderRadius: BorderRadius.circular(256.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

sealed class ShrinkingNavigationNotification extends Notification {}

class ShrinkingNavigationUpdateNotification extends ShrinkingNavigationNotification {
  ShrinkingNavigationUpdateNotification(this.index);

  final int index;
}
