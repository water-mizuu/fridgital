/// An immutable wrapper around a [List] that restricts in-place modification and mutation.
class ImmutableList<E> extends Iterable<E> {
  const ImmutableList(this.values);

  final List<E> values;

  E operator [](int index) => values[index];

  @override
  Iterator<E> get iterator => values.iterator;
}
