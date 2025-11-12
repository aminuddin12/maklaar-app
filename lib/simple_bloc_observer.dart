// simple_bloc_observer.dart
import 'package:flutter/foundation.dart'; // Import foundation untuk debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Log ini sudah sangat membantu!
    debugPrint('${bloc.runtimeType} | ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  /// =================================================================
  ///                       BAGIAN YANG DIPERBAIKI
  /// =================================================================
  /// Kita akan membuat log error lebih informatif untuk debugging.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('================= BLOC ERROR =================');
    debugPrint('BLOC: ${bloc.runtimeType}');
    debugPrint('ERROR: $error');
    debugPrint('STACK TRACE:\n$stackTrace');
    debugPrint('==============================================');
    super.onError(bloc, error, stackTrace);
  }
}
