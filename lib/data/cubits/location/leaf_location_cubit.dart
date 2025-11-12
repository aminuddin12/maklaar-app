import 'dart:developer';

import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/repositories/location/location_repository.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/location_utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the currently selected or active [LeafLocation].
///
/// This is usually used by UI widgets like `location_widget` to reflect the
/// latest location info instantly, instead of waiting for callback-based updates.
///
/// Think of it as a live feed of "where we at right now?" in the app.
class LeafLocationCubit extends Cubit<LeafLocation?> {
  LeafLocationCubit() : super(null) {
    final location = HiveUtils.getLocationV2();
    emit(location);
  }

  void setLocation(LeafLocation? location) {
    emit(location);
    HiveUtils.setLocationV2(location: location ?? LeafLocation());
    LocationUtility().location = location;
  }

  /// Re-fetches the current location intelligently.
  ///
  /// Checks what data is available and picks the best option to refresh:
  /// - If `placeId` is present, fetches full details via place API.
  /// - If coordinates are available, does a reverse geocode lookup.
  /// - Otherwise, just re-emits the persisted localization info.
  ///
  /// Handy when the user changes language and we need to refresh the location in the new locale.
  void refresh() {
    if (state == null) return;
    if (state!.placeId != null && Constant.mapProvider != 'free_api') {
      _updateLocationFromPlaceId();
    } else if (state!.hasCoordinates) {
      _updateLocationFromCoordinates();
    } else {
      final location = LeafLocation(
        area: state?.area,
        city: state?.city,
        state: state?.state,
        country: state?.country,
      );
      emit(location);
    }
  }

  void _updateLocationFromPlaceId() async {
    try {
      final location = await LocationRepository().getLocationFromPlaceId(
        placeId: state!.placeId!,
      );
      final effectiveLocation = location.copyWith(
        radius: state?.radius ?? Constant.minRadius,
      );
      emit(effectiveLocation);
      HiveUtils.setLocationV2(location: effectiveLocation);
    } on Exception catch (e, stack) {
      log('$e', name: 'updateLocationFromPlaceId');
      log('$stack', name: 'updateLocationFromPlaceId');
    }
  }

  void _updateLocationFromCoordinates() async {
    try {
      final location = await LocationRepository().getLocationFromLatLng(
        latitude: state!.latitude!,
        longitude: state!.longitude!,
      );

      final effectiveLocation = LeafLocation(
        area: state!.hasArea ? location.area : null,
        city: state!.hasCity ? location.city : null,
        state: state!.hasState ? location.state : null,
        country: state!.hasCountry ? location.country : null,
        radius: state?.radius ?? Constant.minRadius,
        latitude: state!.latitude,
        longitude: state!.longitude,
        placeId: state!.placeId,
      );
      emit(effectiveLocation);
      HiveUtils.setLocationV2(location: effectiveLocation);
    } on Exception catch (e, stack) {
      log('$e', name: 'updateLocationFromCoordinates');
      log('$stack', name: 'updateLocationFromCoordinates');
    }
  }
}
