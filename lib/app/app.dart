import 'package:com.maklaar.app/firebase_options.dart';
import 'package:com.maklaar.app/main.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/hive_keys.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:com.maklaar.app/simple_bloc_observer.dart';

/// List of Hive box names that need to be initialized
final List<String> _hiveBoxes = [
  HiveKeys.userDetailsBox,
  HiveKeys.translationsBox,
  HiveKeys.authBox,
  HiveKeys.languageBox,
  HiveKeys.themeBox,
  HiveKeys.svgBox,
  HiveKeys.jwtToken,
  HiveKeys.historyBox,
];

/// Initializes the application with all necessary configurations
Future<void> initApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Configure Google Maps for Android
    _configureGoogleMaps();
    Bloc.observer = SimpleBlocObserver();

    // Set up error handling for release mode
    if (kReleaseMode) {
      _setupErrorHandling();
    }

    // Initialize Firebase
    await _initializeFirebase();

    // Initialize Mobile Ads
    await MobileAds.instance.initialize();

    // Initialize Hive and open boxes
    await _initializeHive();

    // Configure system UI and launch app
    await _configureSystemUI();

    Constant.savePath = await getApplicationDocumentsDirectory().then(
      (dir) => dir.path,
    );

    runApp(const EntryPoint());
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e\n$stackTrace');
    rethrow;
  }
}



/// Configures Google Maps for Android platform
void _configureGoogleMaps() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = false;
  }
}

/// Sets up error handling for release mode
void _setupErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return SomethingWentWrong();
  };
}

/// Initializes Firebase with appropriate options
Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    androidProvider: AndroidProvider.playIntegrity,
  );
}

/// Initializes Hive and opens all required boxes
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  for (final boxName in _hiveBoxes) {
    await Hive.openBox(boxName);
  }
}

/// Configures system UI and launches the app
Future<void> _configureSystemUI() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}
