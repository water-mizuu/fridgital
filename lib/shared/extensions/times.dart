extension TimesExtension on int {
  Iterable<int> get times sync* {
    for (var i = 0; i < this; ++i) {
      yield i;
    }
  }

  Iterable<int> until(int target) sync* {
    if (target < this) {
      for (var i = this; i > target; --i) {
        yield i;
      }
    } else {
      for (var i = this; i < target; ++i) {
        yield i;
      }
    }
  }

  Iterable<int> to(int target) sync* {
    if (target < this) {
      for (var i = this; i >= target; --i) {
        yield i;
      }
    } else {
      for (var i = this; i <= target; ++i) {
        yield i;
      }
    }
  }
}
