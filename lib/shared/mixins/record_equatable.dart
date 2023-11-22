mixin RecordEquatable {
  Record get record;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RecordEquatable && this.record == other.record;
  }

  @override
  int get hashCode => record.hashCode;

  @override
  String toString() => "$runtimeType<$record>";
}
