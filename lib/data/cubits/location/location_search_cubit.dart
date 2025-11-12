import 'dart:developer';

import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/repositories/location/location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LocationSearchState {}

class LocationSearchInitial extends LocationSearchState {}

class LocationSearchLoading extends LocationSearchState {}

class LocationSearchSuccess extends LocationSearchState {
  LocationSearchSuccess({required this.locations});

  final List<LeafLocation> locations;
}

class LocationSearchSelecting extends LocationSearchState {}

class LocationSearchSelected extends LocationSearchState {
  LocationSearchSelected({required this.location});

  final LeafLocation location;
}

class LocationSearchFailure extends LocationSearchState {
  LocationSearchFailure({required this.errorMessage});

  final String errorMessage;
}

class LocationSearchCubit extends Cubit<LocationSearchState> {
  LocationSearchCubit() : super(LocationSearchInitial());

  Future<void> searchLocations({required String? search}) async {
    try {
      if (search == null || search.isEmpty) {
        clearSearch();
        return;
      }
      emit(LocationSearchLoading());

      final locations = await LocationRepository().searchLocation(
        search: search,
      );

      emit(LocationSearchSuccess(locations: locations));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'searchLocations');
      log('$stack', name: 'searchLocations');
      emit(LocationSearchFailure(errorMessage: e.toString()));
    }
  }

  void clearSearch() => emit(LocationSearchInitial());

  Future<void> selectLocation({required String placeId}) async {
    try {
      emit(LocationSearchSelecting());
      final location = await LocationRepository().getLocationFromPlaceId(
        placeId: placeId,
      );
      emit(LocationSearchSelected(location: location));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'selectLocation');
      log('$stack', name: 'selectLocation');
    }
  }
}
