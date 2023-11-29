import "package:flutter/foundation.dart";

/// An immutable wrapper around a [List] that restricts in-place modification and mutation.
@immutable
class ImmutableList<E> extends Iterable<E> {
  const ImmutableList(this.values);

  final List<E> values;

  E operator [](int index) => values[index];

  @override
  Iterator<E> get iterator => values.iterator;

  @override
  int get hashCode => values.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ImmutableList<E> && //
      values.length == other.values.length &&
      List.generate(values.length, (index) => index).every((i) => values[i] == other.values[i]);
}
