import "package:flutter/material.dart";

/// Represents a resource that can be subscribed to by a [State] and disposed of when the [State] is disposed of.
class Resource<T> {
  const Resource({required this.init, required this.dispose});
  Resource.value({required T value, required void Function(T) dispose})
      : init = (() => value),
        dispose = (() => dispose(value));

  final T Function() init;
  final void Function() dispose;

  T subscribedTo(ResourceHostMixin host) {
    var value = init();
    host.addResource(this);

    return value;
  }
}

/// A mixin that allows a [Resource]s to be linked to [State]s.
mixin ResourceHostMixin<T extends StatefulWidget> on State<T> {
  final List<Resource<void>> _resources = [];

  @override
  void dispose() {
    for (var resource in _resources) {
      resource.dispose();
    }
    super.dispose();
  }

  void addResource(Resource<void> resource) {
    _resources.add(resource);
  }
}

extension ResourceExtension<T> on T {
  Resource<T> asResource(void Function(T) dispose) => Resource<T>.value(value: this, dispose: dispose);
}
