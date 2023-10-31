import "package:flutter/material.dart";
import "package:fridgital/icons/figma_icon_font.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/times.dart";
import "package:fridgital/widgets/inherited_widgets/tab_information.dart";
import "package:fridgital/widgets/shared/helper/animated_transform.dart";

class ShrinkingNavigation extends StatefulWidget {
  const ShrinkingNavigation({required this.latestScrollOffset, super.key});

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
  bool isRetracted = false;

  void updateRetracted() {
    setState(() {
      isRetracted = widget.latestScrollOffset.value > 0.0;
    });
  }

  void toggleRetracted() {
    setState(() => isRetracted = !isRetracted);
  }

  void updateOffsets() {
    if (parentKey.currentContext?.findRenderObject() case RenderBox parentBox) {
      for (var (i, key) in navigationKeys.indexed) {
        if (key.currentContext?.findRenderObject() case RenderBox box) {
          navigationOffsets[i] = box.localToGlobal(Offset.zero, ancestor: parentBox) +
              Offset(0.0, box.size.height * 1.0625) +
              Offset(box.size.width / 2, 0.0) +
              const Offset(-8.0, 0.0);
        }
      }

      /// Compute the difference.
      if (retractedKey.currentContext?.findRenderObject() case RenderBox retractedBox) {
        if (expandedKey.currentContext?.findRenderObject() case RenderBox expandedBox) {
          retractedOffset = expandedBox.localToGlobal(Offset.zero) - retractedBox.localToGlobal(Offset.zero);
        }
      }

      setState(() => hasComputedOffsets = true);
    }
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

  bool hasComputedOffsets = false;
  GlobalKey parentKey = GlobalKey();

  GlobalKey retractedKey = GlobalKey();
  GlobalKey expandedKey = GlobalKey();

  Offset retractedOffset = Offset.zero;

  List<Offset> navigationOffsets = List.generate(4, (_) => Offset.zero);
  List<GlobalKey> navigationKeys = List.generate(4, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    const ghostOpacity = 0.00;
    const retractDuration = Duration(milliseconds: 125);

    const iconSize = 32.0;
    const margin = 20.0;
    const padding = 8.0;
    const indicator = (width: 16.0, height: 4.0);

    var activeIndex = TabInformation.of(context).index;
    var width = MediaQuery.sizeOf(context).width - margin * 2 - padding * 2;
    var arbitraryRetracted = iconSize + padding * 2;

    return Padding(
      padding: const EdgeInsets.all(margin),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          /// Evaluated if the navigation is retracted
          IgnorePointer(
            child: Opacity(
              opacity: ghostOpacity,
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
                        for (void _ in 4.times) const SizedBox(height: iconSize, width: iconSize),
                        Icon(Icons.menu, size: iconSize, color: FigmaColors.pinkAccent, key: retractedKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Evaluated if the navigation is not retracted
          IgnorePointer(
            child: Opacity(
              opacity: ghostOpacity,
              child: Container(
                padding: const EdgeInsets.all(padding),
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
                        for (var i = 0; i < 4; ++i) const SizedBox(height: iconSize, width: iconSize),
                        Icon(null, size: iconSize, key: expandedKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Actual displayed.
          AnimatedContainer(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: FigmaColors.whiteAccent,
              borderRadius: BorderRadius.circular(256.0),
            ),
            onEnd: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!isRetracted) {
                  updateOffsets();
                }
              });
            },
            duration: retractDuration,
            width: isRetracted ? arbitraryRetracted : width,
            curve: Curves.fastOutSlowIn,
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
                        for (int i in 4.times)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
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
                        AnimatedTransform.translate(
                          duration: retractDuration,
                          offset: isRetracted ? -retractedOffset : Offset.zero,
                          curve: Curves.fastOutSlowIn,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: toggleRetracted,
                              child: const Icon(Icons.menu, size: iconSize, color: FigmaColors.pinkAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isRetracted && hasComputedOffsets)
                  AnimatedTransform.translate(
                    offset: navigationOffsets[activeIndex],
                    duration: retractDuration,
                    curve: Curves.fastOutSlowIn,
                    child: Opacity(
                      opacity: isRetracted ? 0.0 : 1.0,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

sealed class ShrinkingNavigationNotification extends Notification {}

class ShrinkingNavigationUpdateNotification extends ShrinkingNavigationNotification {
  ShrinkingNavigationUpdateNotification(this.index);

  final int index;
}
