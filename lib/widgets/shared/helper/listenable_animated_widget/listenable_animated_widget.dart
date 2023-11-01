import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// An abstract class for building widgets that animate changes to their
/// properties. This includes additional properties that allows finer control
/// over the lifetime of the animation.
abstract class ListenableImplicitlyAnimatedWidget extends ImplicitlyAnimatedWidget {
  /// Initializes fields for subclasses.
  const ListenableImplicitlyAnimatedWidget({
    required super.duration,
    super.key,
    super.curve = Curves.linear,
    this.onForward,
    this.onReverse,
    this.onDismiss,
    super.onEnd,
  });

  /// Called every time an animation starts.
  final VoidCallback? onForward;

  /// Called every time an animation reverses.
  final VoidCallback? onReverse;

  /// Called every time an animation dismisses.
  final VoidCallback? onDismiss;

  @override
  ListenableImplicitlyAnimatedWidgetState<ListenableImplicitlyAnimatedWidget> createState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty("duration", duration.inMilliseconds, unit: "ms"));
  }
}

/// A base class for the `State` of widgets with implicit animations.
///
/// [ListenableImplicitlyAnimatedWidgetState] requires that subclasses respond to the
/// animation themselves. If you would like `setState()` to be called
/// automatically as the animation changes, use [ListenableAnimatedWidgetBaseState].
///
/// Properties that subclasses choose to animate are represented by [Tween]
/// instances. Subclasses must implement the [forEachTween] method to allow
/// [ListenableImplicitlyAnimatedWidgetState] to iterate through the widget's fields and
/// animate them.
abstract class ListenableImplicitlyAnimatedWidgetState<T extends ListenableImplicitlyAnimatedWidget>
    extends ImplicitlyAnimatedWidgetState<T> {
  @override
  void initState() {
    super.initState();
    super.controller.addStatusListener((status) {
      if (status case AnimationStatus.dismissed) {
        widget.onDismiss?.call();
      } else if (status case AnimationStatus.forward) {
        widget.onForward?.call();
      } else if (status case AnimationStatus.reverse) {
        widget.onReverse?.call();
      }
    });
  }
}

abstract class ListenableAnimatedWidgetBaseState<T extends ListenableImplicitlyAnimatedWidget>
    extends ListenableImplicitlyAnimatedWidgetState<T> {
  @override
  void initState() {
    super.initState();
    controller.addListener(_handleAnimationChanged);
  }

  void _handleAnimationChanged() {
    setState(() {/* The animation ticked. Rebuild with new animation value */});
  }
}
