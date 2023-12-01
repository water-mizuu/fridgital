import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Returns a [GlobalKey] that persists through rebuilds until disposal.
GlobalKey useGlobalKey({String? debugLabel}) => useMemoized(() => GlobalKey(debugLabel: debugLabel));
