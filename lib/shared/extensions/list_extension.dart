extension ImmutableListExtensions<E> on List<E> {
  /// Returns a new list with the elements of this list sorted.
  List<E> sorted([int Function(E a, E b)? compare]) => [...this]..sort(compare);
}
