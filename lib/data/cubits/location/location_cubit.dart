import 'dart:developer';

import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/model/location/location.dart';
import 'package:com.maklaar.app/data/model/location/location_node.dart';
import 'package:com.maklaar.app/data/repositories/location/location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _LocationType { country, state, city, area }

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSuccess<T extends LocationNode> extends LocationState {
  LocationSuccess({required this.values, required this.location});

  final List<T> values;
  final Location location;
}

class LocationSelected extends LocationState {
  LocationSelected({required this.location});

  final LeafLocation? location;
}

class LocationFailure extends LocationState {
  LocationFailure({required this.errorMessage});

  final String errorMessage;
}

/// A Cubit to manage location selection across hierarchical levels:
/// Country → State → City → Area.
///
/// It fetches location nodes from [LocationRepository] in a paginated way,
/// caches intermediate results, and emits [LocationState] updates based on
/// user selection flow.
///
/// Automatically progresses the user when a level has only one option (e.g. only one country).
class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  /// Current in-progress selection (mutable state tracked internally).
  /// Gets updated after each selection level is chosen
  Location _location = Location.empty();

  /// Caches location data per level (e.g. states for selected country) to:
  /// - Avoid re-fetching
  /// - Support pagination via stored page index
  /// - Determine if there's more data (`hasMore`)
  final Map<_LocationType, _LocationData> _cachedValues = Map.identity();

  final _repo = LocationRepository();

  /// Starts the selection flow by loading the list of countries.
  ///
  /// If only one country is available, auto-selects it and moves to states.
  ///
  /// Emits:
  /// - [LocationLoading]
  /// - [LocationSuccess<Country>] on success
  /// - [LocationFailure] on error
  Future<void> loadCountries() async {
    try {
      emit(LocationLoading());
      _resetValues();
      List<Country>? countries = _cachedValues[_LocationType.country]?.data
          .cast<Country>();
      if (countries == null || countries.isEmpty) {
        final response = await _repo.fetchLocation<Country>(id: null);
        countries = response['data'] as List<Country>;
        _cachedValues[_LocationType.country] = _LocationData(
          data: countries,
          hasMore: response['total'] as int > countries.length,
        );
      }

      if (countries.length == 1) {
        _location = _location.copyWith(country: countries.first);
        _loadLocation<State>(type: _LocationType.state, id: countries.first.id);
        return;
      }

      emit(LocationSuccess<Country>(values: countries, location: _location));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'loadCountries');
      log('$stack', name: 'loadCountries');
      emit(LocationFailure(errorMessage: e.toString()));
    }
  }

  /// Loads data for a given location type [T] (Country, State, City, Area).
  /// Internally used by `loadCountries`, `loadMore`, and selection methods.
  ///
  /// Emits:
  /// - [LocationLoading] when page 1
  /// - [LocationSuccess<T>] with new or cached data
  /// - [LocationSelected] when a level has no children (e.g., no areas)
  /// - [LocationFailure] on error
  Future<void> _loadLocation<T extends LocationNode>({
    required _LocationType type,
    required int id,
  }) async {
    try {
      final locationData = _cachedValues[type];

      if (locationData == null || locationData.page == 1) {
        emit(LocationLoading());
      }

      final response = await _repo.fetchLocation<T>(
        id: id,
        page: locationData?.page ?? 1,
      );

      final data = [
        ...?_cachedValues[type]?.data as List<T>?,
        ...response['data'] as List<T>,
      ];

      if (data.isEmpty) {
        emit(LocationSelected(location: _location.toLeafLocation()));
        _resetValues();
      } else {
        if (_cachedValues[type] == null) {
          _cachedValues[type] = _LocationData(
            data: data,
            hasMore: response['total'] as int > data.length,
          );
        } else {
          _cachedValues[type] = _cachedValues[type]!.copyWith(
            data: data,
            hasMore: response['total'] as int > data.length,
          );
        }

        emit(LocationSuccess<T>(values: data, location: _location));
      }
    } on Exception catch (e, stack) {
      log(e.toString(), name: '_loadLocation<$T>');
      log('$stack', name: '_loadLocation<$T>');
      emit(LocationFailure(errorMessage: e.toString()));
    }
  }

  /// Whether more paginated data is available for the current level.
  ///
  /// Depends on last selected node and `_cachedValues` state.
  bool hasMore() {
    final lastNode = (state as LocationSuccess).location.lastNode;
    final locationType = switch (lastNode.runtimeType) {
      Null => _LocationType.country,
      Country => _LocationType.state,
      State => _LocationType.city,
      City => _LocationType.area,
      _ => throw StateError('No Such Type'),
    };

    return _cachedValues[locationType]?.hasMore ?? false;
  }

  /// Loads the next page of data for the current location level (if available).
  ///
  /// No-op if `hasMore` is false.
  /// Emits:
  /// - [LocationLoading] during fetch
  /// - [LocationSuccess<T>] on success
  /// - [LocationFailure] on error
  Future<void> loadMore() async {
    try {
      final lastNode = (state as LocationSuccess).location.lastNode;
      final locationType = switch (lastNode.runtimeType) {
        Null => _LocationType.country,
        Country => _LocationType.state,
        State => _LocationType.city,
        City => _LocationType.area,
        _ => throw StateError('No Such Type'),
      };

      switch (locationType) {
        case _LocationType.country:
          _loadLocation<Country>(type: _LocationType.country, id: -1);
        case _LocationType.state:
          _loadLocation<State>(
            type: _LocationType.state,
            id: (lastNode as Country).id,
          );
        case _LocationType.city:
          _loadLocation<City>(
            type: _LocationType.city,
            id: (lastNode as State).id,
          );
        case _LocationType.area:
          _loadLocation<Area>(
            type: _LocationType.area,
            id: (lastNode as City).id,
          );
      }
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'loadMore');
      log('$stack', name: 'loadMore');
      emit(LocationFailure(errorMessage: e.toString()));
    }
  }

  /// Finalizes selection with the current in-progress location.
  ///
  /// Emits:
  /// - [LocationSelected] with current location
  /// Also clears cached state.
  void selectCurrentNode() {
    emit(LocationSelected(location: _location.toLeafLocation()));
    _resetValues();
  }

  /// Handles user selection of a node (Country/State/City/Area).
  ///
  /// - Updates `_location`
  /// - Loads the next child level if applicable
  /// - Finalizes selection if Area is selected
  ///
  /// Emits:
  /// - [LocationSuccess<T>] with new child nodes
  /// - [LocationSelected] when Area is selected
  void selectLocation({required LocationNode location}) {
    switch (location.runtimeType) {
      case Country:
        _location = _location.copyWith(country: location as Country);
        _loadLocation<State>(type: _LocationType.state, id: location.id);
      case State:
        _location = _location.copyWith(
          country: _location.country,
          state: location as State,
        );
        _loadLocation<City>(type: _LocationType.city, id: location.id);
      case City:
        _location = _location.copyWith(
          country: _location.country,
          state: _location.state,
          city: location as City,
        );
        _loadLocation<Area>(type: _LocationType.area, id: location.id);
      case Area:
        _location = _location.copyWith(
          country: _location.country,
          state: _location.state,
          city: _location.city,
          area: location as Area,
        );
        emit(LocationSelected(location: _location.toLeafLocation()));
        _resetValues();
    }
  }

  /// Allows user to go back to a specific location level:
  /// - Country → show states
  /// - State → show cities
  /// - null → reset to countries
  ///
  /// Emits:
  /// - [LocationSuccess<T>] for appropriate level
  void navigateBackTo({required LocationNode? location}) {
    switch (location.runtimeType) {
      case Country:
        _location = _location.copyWith(country: location as Country);
        _cachedValues.remove(_LocationType.city);
        _cachedValues.remove(_LocationType.area);
        emit(
          LocationSuccess<State>(
            values: _cachedValues[_LocationType.state]!.data.cast<State>(),
            location: _location,
          ),
        );
      case State:
        _location = _location.copyWith(
          country: _location.country,
          state: location as State,
        );
        _cachedValues.remove(_LocationType.area);
        emit(
          LocationSuccess<City>(
            values: _cachedValues[_LocationType.city]!.data.cast<City>(),
            location: _location,
          ),
        );
      case _:
        // If there is only one country then we should not allow navigation to
        // the country list
        if (_cachedValues[_LocationType.country]?.data.length == 1) break;
        _location = Location.empty();
        _cachedValues.remove(_LocationType.state);
        _cachedValues.remove(_LocationType.city);
        _cachedValues.remove(_LocationType.area);
        emit(
          LocationSuccess<Country>(
            values: _cachedValues[_LocationType.country]!.data.cast<Country>(),
            location: _location,
          ),
        );
    }
  }

  /// Clears internal state except countries (used for restart or finalization).
  ///
  /// Keeps country cache so user doesn't re-download it again.
  void _resetValues() {
    _location = Location.empty();
    _cachedValues.remove(_LocationType.state);
    _cachedValues.remove(_LocationType.city);
    _cachedValues.remove(_LocationType.area);
  }
}

class _LocationData {
  _LocationData({required this.data, required this.hasMore})
    : page = hasMore ? 2 : 1;

  _LocationData._({
    required this.data,
    required this.page,
    required this.hasMore,
  });

  final List<LocationNode> data;
  final int page;
  final bool hasMore;

  _LocationData copyWith({
    required List<LocationNode> data,
    required bool hasMore,
  }) => _LocationData._(
    data: data,
    hasMore: hasMore,
    page: hasMore ? this.page + 1 : this.page,
  );

  @override
  String toString() {
    return '_LocationData{data: $data, page: $page, hasMore: $hasMore}';
  }
}
