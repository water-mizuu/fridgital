final class Reference<T> {
  Reference(this._object);

  T _object;
  T get value => _object;
  set value(T object) => this._object = object;

  void dispose() {}

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(T, _object);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reference<T> && //
          other._captureGeneric(<R>() => T == R) &&
          other._object == _object;

  O _captureGeneric<O>(O Function<T>() callback) => callback<T>();
}
