/// Holds a reference to an object that can be passed around as function arguments,
///   allowing mutation of variables outside of the current scope.
/// This is dangerous, and should be used sparingly.
final class Reference<T> {
  Reference(this._object);

  T _object;
  T get value => _object;
  set value(T object) => this._object = object;

  void dispose() {}

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => throw UnsupportedError("Reference should not be used in a hash map.");

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reference<T> && //
          other._captureGeneric(<R>() => T == R) &&
          other._object == _object;

  O _captureGeneric<O>(O Function<T>() callback) => callback<T>();
}
