import "package:flutter/material.dart";
import "package:fridgital/widgets/shared/helper/listenable_animated_widget/listenable_animated_widget.dart";

class ListenableAnimatedTransform extends ListenableImplicitlyAnimatedWidget {
  // ignore: unreachable_from_main
  const ListenableAnimatedTransform({
    required this.transform,
    required this.child,
    required super.duration,
    super.curve,
    super.key,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.onEnd,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.filterQuality,
  });

  ListenableAnimatedTransform.translate({
    required Offset offset,
    required super.duration,
    super.curve,
    super.key,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.onEnd,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  })  : transform = Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        origin = null,
        alignment = null;

  final Matrix4 transform;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;
  final Widget? child;

  @override
  AnimatedTransformState createState() => AnimatedTransformState();
}

final class AnimatedTransformState extends ListenableAnimatedWidgetBaseState<ListenableAnimatedTransform> {
  Matrix4Tween? transform;
  Tween<Offset>? origin;
  AlignmentGeometryTween? alignment;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: transform!.evaluate(animation),
      origin: origin?.evaluate(animation),
      alignment: alignment?.evaluate(animation),
      transformHitTests: widget.transformHitTests,
      filterQuality: widget.filterQuality,
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<Object?> visitor) {
    transform = visitor(
      transform,
      widget.transform,
      (value) => Matrix4Tween(begin: value as Matrix4?),
    ) as Matrix4Tween?;

    origin = visitor(
      origin,
      widget.origin,
      (value) => Tween<Offset>(begin: value as Offset?),
    ) as Tween<Offset>?;

    alignment = visitor(
      alignment,
      widget.alignment,
      (value) => AlignmentGeometryTween(begin: value as AlignmentGeometry?),
    ) as AlignmentGeometryTween?;
  }
}
