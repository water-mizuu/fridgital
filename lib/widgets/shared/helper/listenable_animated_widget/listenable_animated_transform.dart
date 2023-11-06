// ignore_for_file: comment_references

import "dart:math" as math;

import "package:flutter/material.dart";
import "package:fridgital/widgets/shared/helper/listenable_animated_widget/listenable_animated_widget.dart";

class ListenableAnimatedTransform extends ListenableImplicitlyAnimatedWidget {
  /// Creates a widget that transforms its child.
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

  /// Creates a widget that transforms its child using a rotation around the
  /// center.
  ///
  /// The `angle` argument gives the rotation in clockwise radians.
  ///
  /// {@tool snippet}
  ///
  /// This example rotates an orange box containing text around its center by
  /// fifteen degrees.
  ///
  /// ```dart
  /// Transform.rotate(
  ///   angle: -math.pi / 12.0,
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFFE8581C),
  ///     child: const Text('Apartment for rent!'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [RotationTransition], which animates changes in rotation smoothly
  ///    over a given duration.
  ListenableAnimatedTransform.rotate({
    required double angle,
    required super.duration,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.curve,
    super.key,
    this.origin,
    this.alignment = Alignment.center,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  }) : transform = _computeRotation(angle);

  /// Creates a widget that transforms its child using a translation.
  ///
  /// The `offset` argument specifies the translation.
  ///
  /// {@tool snippet}
  ///
  /// This example shifts the silver-colored child down by fifteen pixels.
  ///
  /// ```dart
  /// ListenableAnimatedTransform.translate(
  ///   offset: const Offset(0.0, 15.0),
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFF7F7F7F),
  ///     child: const Text('Quarter'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ListenableAnimatedTransform.translate({
    required Offset offset,
    required super.duration,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.curve,
    super.key,
    super.onEnd,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  })  : transform = Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        origin = null,
        alignment = null;

  /// Creates a widget that scales its child along the 2D plane.
  ///
  /// The `scaleX` argument provides the scalar by which to multiply the `x`
  /// axis, and the `scaleY` argument provides the scalar by which to multiply
  /// the `y` axis. Either may be omitted, in which case the scaling factor for
  /// that axis defaults to 1.0.
  ///
  /// For convenience, to scale the child uniformly, instead of providing
  /// `scaleX` and `scaleY`, the `scale` parameter may be used.
  ///
  /// At least one of `scale`, `scaleX`, and `scaleY` must be non-null. If
  /// `scale` is provided, the other two must be null; similarly, if it is not
  /// provided, one of the other two must be provided.
  ///
  /// The [alignment] controls the origin of the scale; by default, this is the
  /// center of the box.
  ///
  /// {@tool snippet}
  ///
  /// This example shrinks an orange box containing text such that each
  /// dimension is half the size it would otherwise be.
  ///
  /// ```dart
  /// ListenableAnimatedTransform.scale(
  ///   scale: 0.5,
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFFE8581C),
  ///     child: const Text('Bad Idea Bears'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  /// * [ScaleTransition], which animates changes in scale smoothly over a given
  ///   duration.
  ListenableAnimatedTransform.scale({
    required super.duration,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.onEnd,
    super.curve,
    super.key,
    double? scale,
    double? scaleX,
    double? scaleY,
    this.origin,
    this.alignment = Alignment.center,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  })  : assert(
          !(scale == null && scaleX == null && scaleY == null),
          "At least one of 'scale', 'scaleX' and 'scaleY' is required to be non-null",
        ),
        assert(
          scale == null || (scaleX == null && scaleY == null),
          "If 'scale' is non-null then 'scaleX' and 'scaleY' must be left null",
        ),
        transform = Matrix4.diagonal3Values(scale ?? scaleX ?? 1.0, scale ?? scaleY ?? 1.0, 1.0);

  /// Creates a widget that mirrors its child about the widget's center point.
  ///
  /// If `flipX` is true, the child widget will be flipped horizontally. Defaults to false.
  ///
  /// If `flipY` is true, the child widget will be flipped vertically. Defaults to false.
  ///
  /// If both are true, the child widget will be flipped both vertically and horizontally, equivalent to a 180 degree rotation.
  ///
  /// {@tool snippet}
  ///
  /// This example flips the text horizontally.
  ///
  /// ```dart
  /// ListenableAnimatedTransform.flip(
  ///   flipX: true,
  ///   child: const Text('Horizontal Flip'),
  /// )
  /// ```
  /// {@end-tool}
  ListenableAnimatedTransform.flip({
    required super.duration,
    super.onForward,
    super.onReverse,
    super.onDismiss,
    super.onEnd,
    super.curve,
    super.key,
    bool flipX = false,
    bool flipY = false,
    this.origin,
    this.transformHitTests = true,
    this.filterQuality,
    this.child,
  })  : alignment = Alignment.center,
        transform = Matrix4.diagonal3Values(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0, 1.0);

  /// The matrix to transform the child by during painting.
  final Matrix4 transform;

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  final Offset? origin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [origin], both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  final AlignmentGeometry? alignment;

  /// Whether to apply the transformation when performing hit tests.
  final bool transformHitTests;

  /// The filter quality with which to apply the transform as a bitmap operation.
  ///
  /// {@template flutter.widgets.Transform.optional.FilterQuality}
  /// The transform will be applied by re-rendering the child if [filterQuality] is null,
  /// otherwise it controls the quality of an [ImageFilter.matrix] applied to a bitmap
  /// rendering of the child.
  /// {@endtemplate}
  final FilterQuality? filterQuality;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  // Computes a rotation matrix for an angle in radians, attempting to keep rotations
  // at integral values for angles of 0, π/2, π, 3π/2.
  static Matrix4 _computeRotation(double radians) {
    assert(radians.isFinite, "Cannot compute the rotation matrix for a non-finite angle: $radians");
    if (radians == 0.0) {
      return Matrix4.identity();
    }
    var sin = math.sin(radians);
    if (sin == 1.0) {
      return _createZRotation(1.0, 0.0);
    }
    if (sin == -1.0) {
      return _createZRotation(-1.0, 0.0);
    }
    var cos = math.cos(radians);
    if (cos == -1.0) {
      return _createZRotation(0.0, -1.0);
    }
    return _createZRotation(sin, cos);
  }

  static Matrix4 _createZRotation(double sin, double cos) {
    var result = Matrix4.zero();
    result.storage[0] = cos;
    result.storage[1] = sin;
    result.storage[4] = -sin;
    result.storage[5] = cos;
    result.storage[10] = 1.0;
    result.storage[15] = 1.0;
    return result;
  }

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
