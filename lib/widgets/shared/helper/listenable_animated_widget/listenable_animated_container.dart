// ignore_for_file: prefer_asserts_with_message

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/widgets/shared/helper/listenable_animated_widget/listenable_animated_widget.dart";

class ListenableAnimatedContainer extends ListenableImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  ListenableAnimatedContainer({
    required super.duration,
    super.key,
    this.alignment,
    this.padding,
    Color? color,
    Decoration? decoration,
    this.foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
    super.curve,
    super.onForward,
    super.onDismiss,
    super.onReverse,
    super.onEnd,
  })  : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(
          color == null || decoration == null,
          "Cannot provide both a color and a decoration\n"
          'The color argument is just a shorthand for "decoration: BoxDecoration(color: color)".',
        ),
        decoration = decoration ?? (color != null ? BoxDecoration(color: color) : null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Align the [child] within the container.
  ///
  /// If non-null, the container will expand to fill its parent and position its
  /// child within itself according to the given value. If the incoming
  /// constraints are unbounded, then the child will be shrink-wrapped instead.
  ///
  /// Ignored if [child] is null.
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry? alignment;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  final EdgeInsetsGeometry? padding;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration? decoration;

  /// The decoration to paint in front of the child.
  final Decoration? foregroundDecoration;

  /// Additional constraints to apply to the child.
  ///
  /// The constructor `width` and `height` arguments are combined with the
  /// `constraints` argument to set this property.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints? constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  /// The alignment of the origin, relative to the size of the container, if [transform] is specified.
  ///
  /// When [transform] is null, the value of this property is ignored.
  ///
  /// See also:
  ///
  ///  * [Transform.alignment], which is set by this property.
  final AlignmentGeometry? transformAlignment;

  /// The clip behavior when [AnimatedContainer.decoration] is not null.
  ///
  /// Defaults to [Clip.none]. Must be [Clip.none] if [decoration] is null.
  ///
  /// Unlike other properties of [AnimatedContainer], changes to this property
  /// apply immediately and have no animation.
  ///
  /// If a clip is to be applied, the [Decoration.getClipPath] method
  /// for the provided decoration must return a clip path. (This is not
  /// supported by all decorations; the default implementation of that
  /// method throws an [UnsupportedError].)
  final Clip clipBehavior;

  @override
  ListenableAnimatedWidgetBaseState<ListenableAnimatedContainer> createState() => _ListenableAnimatedContainerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AlignmentGeometry>("alignment", alignment, showName: false, defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>("padding", padding, defaultValue: null))
      ..add(DiagnosticsProperty<Decoration>("bg", decoration, defaultValue: null))
      ..add(DiagnosticsProperty<Decoration>("fg", foregroundDecoration, defaultValue: null))
      ..add(DiagnosticsProperty<BoxConstraints>("constraints", constraints, defaultValue: null, showName: false))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>("margin", margin, defaultValue: null))
      ..add(ObjectFlagProperty<Matrix4>.has("transform", transform))
      ..add(DiagnosticsProperty<AlignmentGeometry>("transformAlignment", transformAlignment, defaultValue: null))
      ..add(DiagnosticsProperty<Clip>("clipBehavior", clipBehavior));
  }
}

class _ListenableAnimatedContainerState extends ListenableAnimatedWidgetBaseState<ListenableAnimatedContainer> {
  AlignmentGeometryTween? _alignment;
  EdgeInsetsGeometryTween? _padding;
  DecorationTween? _decoration;
  DecorationTween? _foregroundDecoration;
  BoxConstraintsTween? _constraints;
  EdgeInsetsGeometryTween? _margin;
  Matrix4Tween? _transform;
  AlignmentGeometryTween? _transformAlignment;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment = visitor(
      _alignment,
      widget.alignment,
      (value) => AlignmentGeometryTween(begin: value as AlignmentGeometry),
    ) as AlignmentGeometryTween?;
    _padding = visitor(
      _padding,
      widget.padding,
      (value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
    ) as EdgeInsetsGeometryTween?;
    _decoration = visitor(_decoration, widget.decoration, (value) => DecorationTween(begin: value as Decoration))
        as DecorationTween?;
    _foregroundDecoration = visitor(
      _foregroundDecoration,
      widget.foregroundDecoration,
      (value) => DecorationTween(begin: value as Decoration),
    ) as DecorationTween?;
    _constraints = visitor(
      _constraints,
      widget.constraints,
      (value) => BoxConstraintsTween(begin: value as BoxConstraints),
    ) as BoxConstraintsTween?;
    _margin = visitor(_margin, widget.margin, (value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry))
        as EdgeInsetsGeometryTween?;
    _transform =
        visitor(_transform, widget.transform, (value) => Matrix4Tween(begin: value as Matrix4)) as Matrix4Tween?;
    _transformAlignment = visitor(
      _transformAlignment,
      widget.transformAlignment,
      (value) => AlignmentGeometryTween(begin: value as AlignmentGeometry),
    ) as AlignmentGeometryTween?;
  }

  @override
  Widget build(BuildContext context) {
    var animation = this.animation;
    return Container(
      alignment: _alignment?.evaluate(animation),
      padding: _padding?.evaluate(animation),
      decoration: _decoration?.evaluate(animation),
      foregroundDecoration: _foregroundDecoration?.evaluate(animation),
      constraints: _constraints?.evaluate(animation),
      margin: _margin?.evaluate(animation),
      transform: _transform?.evaluate(animation),
      transformAlignment: _transformAlignment?.evaluate(animation),
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
      ..add(DiagnosticsProperty<AlignmentGeometryTween>("alignment", _alignment, showName: false, defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometryTween>("padding", _padding, defaultValue: null))
      ..add(DiagnosticsProperty<DecorationTween>("bg", _decoration, defaultValue: null))
      ..add(DiagnosticsProperty<DecorationTween>("fg", _foregroundDecoration, defaultValue: null))
      ..add(
        DiagnosticsProperty<BoxConstraintsTween>("constraints", _constraints, showName: false, defaultValue: null),
      )
      ..add(DiagnosticsProperty<EdgeInsetsGeometryTween>("margin", _margin, defaultValue: null))
      ..add(ObjectFlagProperty<Matrix4Tween>.has("transform", _transform))
      ..add(
        DiagnosticsProperty<AlignmentGeometryTween>("transformAlignment", _transformAlignment, defaultValue: null),
      );
  }
}
