import 'dart:async';
import 'dart:developer';

import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/repositories/location/location_repository.dart';
import 'package:com.maklaar.app/ui/screens/widgets/blurred_dialog_box.dart';
import 'package:com.maklaar.app/utils/app_icon.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/custom_text.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:com.maklaar.app/utils/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final class LocationUtility {
  factory LocationUtility() => _instance;

  LocationUtility._internal();

  static final LocationUtility _instance = LocationUtility._internal();

  static final _repo = LocationRepository();

  static LeafLocation? _location;

  LeafLocation? get location => _location;

  set location(LeafLocation? location) {
    // This will only check the reference in memory and not the actual content which
    // is not ideal way, but we keep it like this just for the sake of it as
    // this does not have any downside.
    // Todo(rio): override == in LeafLocation to have better equality
    if (location == _location) return;
    _location = location;
  }

  Future<LocationPermission> _getLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<LeafLocation?> getLocation(BuildContext context) async {
    final permission = await _getLocationPermission();
    final permissionGiven =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (permissionGiven && locationServiceEnabled) {
      await _getLiveLocation();
      return location;
    } else {
      _handlePermissionDenied(
        context,
        permission: permission,
        isLocationServiceEnabled: locationServiceEnabled,
      );
    }
    return null;
  }

  Future<void> _getLiveLocation() async {
    // This will require user to manually tap the my location button to get the current location
    // instead of directly fetching it when the controller is ready.
    // TODO(rio): Refactor this to use last known location during the initial load and immediately fetch the current location once the controller is ready
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          timeLimit: const Duration(seconds: 30),
        ),
      );
    } on TimeoutException catch (_) {
      position = await Geolocator.getLastKnownPosition();
    } on Exception catch (e, stack) {
      log('$e', name: '_getLiveLocation');
      log('$stack', name: '_getLiveLocation');
    }
    if (position == null) {
      _getPersistedLocation();
    } else {
      bool shouldFetch = true;
      if (location?.hasCoordinates ?? false) {
        final newCoordinates = LatLng(position.latitude, position.longitude);
        final oldCoordinates = LatLng(
          location!.latitude!,
          location!.longitude!,
        );
        shouldFetch = _shouldReFetch(oldCoordinates, newCoordinates);
      }
      if (shouldFetch) {
        location = await getLeafLocationFromLatLng(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    }
  }

  /// Determines whether the location is far enough from the previous one
  /// to justify re-fetching data from the server.
  ///
  /// This helps avoid unnecessary API calls if the user hasn't moved much,
  /// especially when spamming the "my location" button.
  ///
  /// Returns `true` if the distance between [oldCoordinates] and [newCoordinates]
  /// is greater than 3 km.
  bool _shouldReFetch(LatLng oldCoordinates, LatLng newCoordinates) {
    final distance = Geolocator.distanceBetween(
      oldCoordinates.latitude,
      oldCoordinates.longitude,
      newCoordinates.latitude,
      newCoordinates.longitude,
    );

    return distance > 3000;
  }

  void _getPersistedLocation() {
    location = HiveUtils.getLocationV2() ?? Constant.defaultLocation;
  }

  Future<LeafLocation> getLeafLocationFromLatLng({
    required double latitude,
    required double longitude,
  }) async {
    return await _repo.getLocationFromLatLng(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void _handlePermissionDenied(
    BuildContext context, {
    required LocationPermission permission,
    required bool isLocationServiceEnabled,
  }) {
    LoadingWidgets.hideLoader(context);

    if (permission == LocationPermission.denied) {
      _showPermissionDeniedMessage(context);
    } else if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedForeverDialog(context);
    } else if (!isLocationServiceEnabled) {
      _showLocationServiceDisabledDialog(context);
    }
  }

  void _showPermissionDeniedForeverDialog(BuildContext context) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        svgImagePath: AppIcons.locationDenied,
        title: 'locationPermissionDenied'.translate(context),
        content: CustomText('weNeedLocationAvailableLbl'.translate(context)),
        cancelButtonName: 'cancelBtnLbl'.translate(context),
        acceptButtonName: 'settingsLbl'.translate(context),
        onAccept: () {
          Geolocator.openAppSettings();
          return Future.value();
        },
      ),
    );
  }

  void _showPermissionDeniedMessage(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'locationPermissionDenied'.translate(context),
    );
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        svgImagePath: AppIcons.locationDenied,
        title: 'locationServiceDisabled'.translate(context),
        content: CustomText(
          'pleaseEnableLocationServicesManually'.translate(context),
        ),
        cancelButtonName: 'cancelBtnLbl'.translate(context),
        acceptButtonName: 'settingsLbl'.translate(context),
        onAccept: () {
          Geolocator.openLocationSettings();
          return Future.value();
        },
      ),
    );
  }
}
