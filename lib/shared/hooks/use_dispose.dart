import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

void useDispose(void Function() callback, [List<Object?>? keys]) {
  return use(_DisposeHook(onDispose: callback, keys: keys));
}

class _DisposeHook extends Hook<void> {
  const _DisposeHook({
    required this.onDispose,
    super.keys,
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
