import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Runs the given [callback] once, when the widget is disposed.
void useDispose(void Function() callback) {
  return use(_DisposeHook(onDispose: callback));
}

class _DisposeHook extends Hook<void> {
  const _DisposeHook({
    required this.onDispose,
  });

  final void Function() onDispose;

  @override
  _DisposeHookState createState() => _DisposeHookState();
}

class _DisposeHookState extends HookState<void, _DisposeHook> {
  @override
  void dispose() {
    hook.onDispose();

    super.dispose();
  }

  @override
  SizedBox build(BuildContext context) => const SizedBox();
}
