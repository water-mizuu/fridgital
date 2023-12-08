import "dart:math";

import "package:flutter/material.dart";

class ListenableList<E> extends ChangeNotifier implements List<E> {
  ListenableList(this._list);

  final List<E> _list;

  @override
  E get first => _list.first;

  @override
  set first(E value) {
    if (_list.first != value) {
      _list.first = value;
      notifyListeners();
    }
  }

  @override
  E get last => _list.last;

  @override
  set last(E value) {
    if (_list.last != value) {
      _list.last = value;
      notifyListeners();
    }
  }

  @override
  int get length => _list.length;

  @override
  set length(int length) {
    if (_list.length != length) {
      _list.length = length;
      notifyListeners();
    }
  }

  @override
  List<E> operator +(List<E> other) => switch ((this, other)) {
        (ListenableList<E>(_list: var left), ListenableList<E>(_list: var right)) => ListenableList<E>(left + right),

        /// Since one of them is not a ListeningList, we have to return a regular List.
        (List<E> left, List<E> right) => left + right,
      };

  @override
  E operator [](int index) => _list[index];

  @override
  void operator []=(int index, E value) {
    if (_list[index] != value) {
      _list[index] = value;
      notifyListeners();
    }
  }

  @override
  void add(E value) {
    _list.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    if (iterable.isNotEmpty) {
      _list.addAll(iterable);
      notifyListeners();
    }
  }

  @override
  bool any(bool Function(E element) test) => _list.any(test);

  @override
  Map<int, E> asMap() => _list.asMap();

  @override
  List<R> cast<R>() => ListenableList(_list.cast<R>());

  @override
  void clear() {
    if (_list.isNotEmpty) {
      _list.clear();
      notifyListeners();
    }
  }

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  E elementAt(int index) => _list.elementAt(index);

  @override
  bool every(bool Function(E element) test) => _list.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) => _list.expand(toElements);

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    if (start < end) {
      _list.fillRange(start, end, fillValue);
      notifyListeners();
    }
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) => _list.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) => _list.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => _list.followedBy(other);

  @override
  void forEach(void Function(E element) action) => _list.forEach(action);

  @override
  Iterable<E> getRange(int start, int end) => _list.getRange(start, end);

  @override
  int indexOf(E element, [int start = 0]) => _list.indexOf(element, start);

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) => _list.indexWhere(test, start);

  @override
  void insert(int index, E element) {
    _list.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    if (iterable.isNotEmpty) {
      _list.insertAll(index, iterable);
      notifyListeners();
    }
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  String join([String separator = ""]) => _list.join(separator);

  @override
  int lastIndexOf(E element, [int? start]) => _list.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) => _list.lastIndexWhere(test, start);

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) => _list.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => _list.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => _list.reduce(combine);

  @override
  bool remove(Object? value) {
    if (_list.remove(value)) {
      notifyListeners();
      return true;
    }

    return false;
  }

  @override
  E removeAt(int index) {
    E value = _list.removeAt(index);
    notifyListeners();

    return value;
  }

  @override
  E removeLast() {
    E value = _list.removeLast();
    notifyListeners();

    return value;
  }

  @override
  void removeRange(int start, int end) {
    if (start < end) {
      _list.removeRange(start, end);
      notifyListeners();
    }
  }

  @override
  void removeWhere(bool Function(E element) test) {
    int previousLength = _list.length;
    _list.removeWhere(test);

    if (_list.length != previousLength) {
      notifyListeners();
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    if (start < end) {
      _list.replaceRange(start, end, replacements);
      notifyListeners();
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    int previousLength = _list.length;
    _list.retainWhere(test);

    if (_list.length != previousLength) {
      notifyListeners();
    }
  }

  @override
  Iterable<E> get reversed => _list.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) {
    if (iterable.isNotEmpty) {
      _list.setAll(index, iterable);
      notifyListeners();
    }
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    if (start < end) {
      _list.setRange(start, end, iterable, skipCount);
      notifyListeners();
    }
  }

  @override
  void shuffle([Random? random]) {
    _list.shuffle(random);
    notifyListeners();
  }

  @override
  E get single => _list.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) => _list.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _list.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => _list.skipWhile(test);

  @override
  void sort([int Function(E a, E b)? compare]) => _list.sort(compare);

  @override
  List<E> sublist(int start, [int? end]) => _list.sublist(start, end);

  @override
  Iterable<E> take(int count) => _list.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => _list.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => _list.toList(growable: growable);

  @override
  Set<E> toSet() => _list.toSet();

  @override
  Iterable<E> where(bool Function(E element) test) => _list.where(test);

  @override
  Iterable<T> whereType<T>() => _list.whereType<T>();
}
