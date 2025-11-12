import 'dart:async';

import 'package:flutter/cupertino.dart';

/// A mixin that provides debouncing logic for search input in [StatefulWidget]s.
///
/// Intended for widgets like [TextField] or [SearchBar] where API calls or logic
/// should be triggered only after the user pauses typing.
///
/// ### Usage
/// The consuming class **must** call [onChanged] inside the widget's `onChanged` callback
/// for the debounce behavior to take effect.
///
/// ```dart
/// TextField(
///   onChanged: onChanged,
/// )
/// ```
///
/// This mixin handles cancellation of the timer and calls [onDebouncedSearch]
/// after a 500ms pause in user input.
///
/// ### Typical Use Case
/// - Search fields
/// - Type-ahead suggestions
/// - Filtering lists
///
/// Override [onDebouncedSearch] to define the behavior when the debounced input triggers.
mixin DebounceSearchMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  void onChanged(String? value) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(
      const Duration(milliseconds: 500),
      () => onDebouncedSearch(value),
    );
  }

  @protected
  void onDebouncedSearch(String? value);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
