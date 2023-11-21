import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/icons/figma_icon_font.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/extensions/find_box.dart";
import "package:fridgital/shared/extensions/normalize_number.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/shared/helper/invisible.dart";
import "package:fridgital/widgets/shared/miscellaneous/clickable_widget.dart";

const indicator = (width: 16.0, height: 4.0);
const retractDuration = Duration(milliseconds: 125);
const iconSize = 32.0;
const margin = 20.0;
const padding = 8.0;

const retractedSize = iconSize + padding * 2;

const shrinkingNavigationOffset = SizedBox(height: 80);

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

class _ShrinkingNavigationState extends State<ShrinkingNavigation> {
  /// State declared before [initState]
  var retractedOffset = Offset.zero;

  final isRetracted = ValueNotifier<bool>(false);
  final parentKey = GlobalKey();
  final retractedKey = GlobalKey();
  final expandedKey = GlobalKey();
  final indicatorKeys = List.generate(4, (_) => GlobalKey());

  /// State declared on demand.
  late final routePopNotifier = RouteState.of(context).popNotifier;

  void updateRetracted() {
    if (widget.latestScrollOffset.value case (<= -15.0 || >= 15.0) && var value) {
      isRetracted.value = value >= 0.0;
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
  void initState() {
    super.initState();

    widget.latestScrollOffset.addListener(updateRetracted);
  }

  @override
  void dispose() {
    widget.latestScrollOffset.removeListener(updateRetracted);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width - margin * 2;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.all(margin),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            /// Actual displayed.
            NotificationListener<_ToggleRetractionNotification>(
              onNotification: (notification) {
                isRetracted.value = !isRetracted.value;
                return true;
              },
              child: _NavigationBarBody(
                isRetracted: isRetracted,
                width: width,
                parentKey: parentKey,
                expandedKey: expandedKey,
                retractedKey: retractedKey,
                indicatorKeys: indicatorKeys,
                controller: widget.controller,
              ),
            ),

            /// Evaluated if the navigation is retracted
            _RetractedBasis(width: width, retractedKey: retractedKey),

            /// Evaluated if the navigation is not retracted
            _ExpandedBasis(width: width, expandedKey: expandedKey),
          ],
        ),
      ),
    );
  }
}

class _NavigationBarBody extends StatefulWidget {
  const _NavigationBarBody({
    required this.isRetracted,
    required this.width,
    required this.parentKey,
    required this.expandedKey,
    required this.retractedKey,
    required this.indicatorKeys,
    required this.controller,
  });

  final ValueNotifier<bool> isRetracted;
  final double width;

  final GlobalKey parentKey;
  final GlobalKey expandedKey;
  final GlobalKey retractedKey;
  final List<GlobalKey> indicatorKeys;

  final TabController controller;

  @override
  State<_NavigationBarBody> createState() => _NavigationBarBodyState();
}

class _NavigationBarBodyState extends State<_NavigationBarBody> with TickerProviderStateMixin {
  late final AnimationController retractionController;

  void _valueChanged() {
    if (widget.isRetracted.value) {
      retractionController.forward(from: 0.0);
    } else {
      retractionController.reverse(from: 1.0);
    }
  }

  @override
  void initState() {
    super.initState();

    retractionController = AnimationController(vsync: this, duration: retractDuration);
    widget.isRetracted.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(_NavigationBarBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(widget.parentKey == oldWidget.parentKey, "The parent key cannot change.");
    assert(widget.expandedKey == oldWidget.expandedKey, "The expanded key cannot change.");
    assert(widget.retractedKey == oldWidget.retractedKey, "The retracted key cannot change.");
    assert(widget.indicatorKeys == oldWidget.indicatorKeys, "The indicator keys cannot change.");

    if (oldWidget.isRetracted != widget.isRetracted) {
      oldWidget.isRetracted.removeListener(_valueChanged);
      widget.isRetracted.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.isRetracted.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: retractionController,
      builder: (context, child) => Container(
        width: lerpDouble(widget.width, retractedSize, retractionController.value),
        decoration: BoxDecoration(
          color: FigmaColors.whiteAccent,
          borderRadius: BorderRadius.circular(256.0),
        ),
        child: child,
      ),
      child: Stack(
        children: [
          UnconstrainedBox(
            key: widget.parentKey,
            constrainedAxis: Axis.vertical,
            alignment: Alignment.centerRight,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: widget.width,
              child: AnimatedBuilder(
                animation: retractionController,
                builder: (context, child) {
                  var expanded = widget.expandedKey.renderBoxNullable?.offset;
                  var retracted = widget.retractedKey.renderBoxNullable?.offset;

                  if (expanded != null && retracted != null) {
                    child = Transform.translate(
                      offset: Offset.lerp(Offset.zero, retracted - expanded, retractionController.value)!,
                      child: child,
                    );
                  }

                  return child!;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 4; ++i) _NavigationIcon(i: i, widget: widget),
                    ClickableWidget(
                      onTap: () {
                        _ToggleRetractionNotification().dispatch(context);
                      },
                      child: const SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: Icon(
                          Icons.menu,
                          size: iconSize,
                          color: FigmaColors.pinkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// We only render this if we are moving.
          if (widget.controller.animation case Animation<double> animation when widget.controller.indexIsChanging)
            IgnorePointer(
              child: ValueListenableBuilder(
                valueListenable: animation,
                builder: (context, value, child) {
                  var TabController(:index, :previousIndex) = widget.controller;
                  var parentBox = widget.parentKey.renderBox;
                  var offset = Offset.lerp(
                    widget.indicatorKeys[previousIndex].renderBox.offsetFrom(parentBox),
                    widget.indicatorKeys[index].renderBox.offsetFrom(parentBox),
                    value.normalize(between: previousIndex, and: index),
                  );

                  return offset != null && offset != Offset.zero
                      ? Transform.translate(offset: offset, child: child)
                      : Opacity(opacity: 0.0, child: child);
                },
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
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.i, required this.widget});

  final int i;
  final _NavigationBarBody widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: ClickableWidget(
            onTap: () {
              ShrinkingNavigationUpdateNotification(i).dispatch(context);
            },
            child: SizedBox(
              height: iconSize,
              width: iconSize,
              child: Icon(
                const [FigmaIconFont.book, FigmaIconFont.fridge, Icons.home_outlined, Icons.list_alt_outlined][i],
                size: iconSize,
                color: FigmaColors.pinkAccent,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: _NavigationIndicator(
            index: i,
            indicatorKey: widget.indicatorKeys[i],
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}

class _NavigationIndicator extends StatelessWidget {
  const _NavigationIndicator({required this.indicatorKey, required this.index, required this.controller});

  final TabController controller;
  final GlobalKey indicatorKey;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: controller.indexIsChanging || controller.index != index ? 0.0 : 1.0,
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              key: indicatorKey,
              width: indicator.width,
              height: indicator.height,
              decoration: BoxDecoration(
                color: FigmaColors.pinkAccent,
                borderRadius: BorderRadius.circular(256.0),
              ),
            ),
            const SizedBox(height: 2.0),
          ],
        ),
      ),
    );
  }
}

class _ExpandedBasis extends StatelessWidget {
  const _ExpandedBasis({required this.width, required this.expandedKey});

  final double width;
  final GlobalKey expandedKey;

  @override
  Widget build(BuildContext context) {
    return Invisible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: padding),
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
    );
  }
}

class _RetractedBasis extends StatelessWidget {
  const _RetractedBasis({required this.width, required this.retractedKey});

  final double width;
  final GlobalKey retractedKey;

  @override
  Widget build(BuildContext context) {
    return Invisible(
      child: Container(
        padding: const EdgeInsets.all(padding),
        width: retractedSize,
        child: SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.menu, size: iconSize, color: FigmaColors.pinkAccent, key: retractedKey),
            ],
          ),
        ),
      ),
    );
  }
}

/// NOTIFICATIONS USED WITHIN THIS FILE

class ShrinkingNavigationUpdateNotification extends Notification {
  const ShrinkingNavigationUpdateNotification(this.index);
  final int index;
}

class _ToggleRetractionNotification extends Notification {}
