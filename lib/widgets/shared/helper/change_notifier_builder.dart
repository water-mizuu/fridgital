import "package:flutter/material.dart";

/// A widget that listens to a [ChangeNotifier] and rebuilds whenever the [ChangeNotifier] notifies its listeners.
///  It is important that widgets that depend on [changeNotifier] are placed inside the [builder] function.
/// If [selector] is provided, the [ChangeNotifierBuilder] will only rebuild
///   when the value returned by [selector] changes.
@optionalTypeArgs
class ChangeNotifierBuilder<T extends ChangeNotifier, S extends Object?> extends StatefulWidget {
  const ChangeNotifierBuilder({
    required this.builder,
    required this.changeNotifier,
    this.selector,
    this.child,
    super.key,
  });

  /// The builder for the [ChangeNotifierBuilder]. It is called whenever the [changeNotifier] notifies its listeners.
  ///   It is important that widgets that depend on [changeNotifier] are placed inside this builder.
  final Widget Function(BuildContext context, T changeNotifier, Widget? child) builder;

  /// [Widget] that is passed to the [builder] function. Useful for widgets
  /// that are constant and do not depend on [changeNotifier] directly.
  final Widget? child;

  /// A class that extends [ChangeNotifier] which the [ChangeNotifierBuilder] listens to.
  final T changeNotifier;

  /// An optional selector that allows the [ChangeNotifierBuilder] to listen to a specific property of [changeNotifier].
  ///
  /// Useful for rebuilding only when the specified property changes.
  final S Function(T)? selector;

  @override
  State<ChangeNotifierBuilder<T, S>> createState() => _ChangeNotifierBuilderState<T, S>();
}

final class _ChangeNotifierBuilderState<T extends ChangeNotifier, S extends Object?>
    extends State<ChangeNotifierBuilder<T, S>> {
  S? latest;

  void _listener() {
    if (widget.selector == null) {
      setState(() {});
      return;
    }

    if (widget.selector!.call(widget.changeNotifier) case S value when value != latest) {
      setState(() {
        latest = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    widget.changeNotifier.addListener(_listener);
  }

  @override
  void dispose() {
    widget.changeNotifier.removeListener(_listener);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChangeNotifierBuilder<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.changeNotifier != oldWidget.changeNotifier) {
      oldWidget.changeNotifier.removeListener(_listener);
      widget.changeNotifier.addListener(_listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.changeNotifier, widget.child);
  }
}
