import 'package:flutter/material.dart';

/// A custom notifier that notifies listeners when the contents of a [Set] change.
///
/// Unlike [ValueNotifier], which only triggers updates when the reference changes,
/// this class observes mutations within the [Set] itself (e.g. adding/removing items).
///
/// Currently tailored for [Set] use cases, but can be extended later to support
/// other [Iterable] types if needed.

class SetNotifier<T> extends ChangeNotifier {
  SetNotifier(Iterable<T> iterable) : _values = Set.from(iterable);
  final Set<T> _values;

  Set<T> get value => Set.unmodifiable(_values);

  int get length => _values.length;

  bool get isEmpty => _values.isEmpty;

  void add(T item) {
    _values.add(item);
    notifyListeners();
  }

  void addAll(Iterable<T> items) {
    _values.addAll(items);
    notifyListeners();
  }

  void delete(T item) {
    _values.remove(item);
    notifyListeners();
  }

  void toggle(T item) {
    if (_values.contains(item)) {
      delete(item);
    } else {
      add(item);
    }
  }

  void clear() {
    _values.clear();
    notifyListeners();
  }
}
