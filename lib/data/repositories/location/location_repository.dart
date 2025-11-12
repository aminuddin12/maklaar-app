import 'dart:developer';

import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/model/location/location_node.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/json_helper.dart';

class LocationRepository {
  factory LocationRepository() => _instance;

  LocationRepository._internal();

  static final LocationRepository _instance = LocationRepository._internal();

  /// A generic method that can fetch locations for all kinds of [LocationNode]s
  /// based on the Generic Type parameter to avoid writing the same methods for each type of
  /// [LocationNode].
  ///
  /// This is also a scalable approach if additional parts are added to the location hierarchy.
  Future<Map<String, dynamic>> fetchLocation<T extends LocationNode>({
    required int? id,
    int page = 1,
  }) async {
    try {
      final endPoint = switch (T) {
        Country => Api.getCountriesApi,
        State => Api.getStatesApi,
        City => Api.getCitiesApi,
        Area => Api.getAreasApi,
        _ => throw UnsupportedError('Unsupported Type $T'),
      };

      final idKey = switch (T) {
        Country => null,
        State => Api.countryId,
        City => Api.stateId,
        Area => Api.cityId,
        _ => throw UnsupportedError('Unsupported Type $T'),
      };

      final response = await Api.get(
        url: endPoint,
        queryParameters: {if (idKey != null) idKey: id, Api.page: page},
      );

      final dataList = switch (T) {
        Country => JsonHelper.parseList(
          response['data']['data'] as List?,
          Country.fromJson,
        ),
        State => JsonHelper.parseList(
          response['data']['data'] as List?,
          State.fromJson,
        ),
        City => JsonHelper.parseList(
          response['data']['data'] as List?,
          City.fromJson,
        ),
        Area => JsonHelper.parseList(
          response['data']['data'] as List?,
          Area.fromJson,
        ),
        _ => throw UnsupportedError('Unsupported Type $T'),
      };

      return {'data': dataList, 'total': response['data']['total']};
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchLocation<$T>');
      log('$stack', name: 'fetchLocation<$T>');
      throw ApiException(e.toString());
    }
  }

  /// Performs a location search using the current map provider.
  ///
  /// This method determines which API to call based on the active map provider,
  /// then extracts and returns a list of [LeafLocation] from the response.
  ///
  /// [search] is the query string entered by the user.
  Future<List<LeafLocation>> searchLocation({required String search}) async {
    final usePaidApi = Constant.mapProvider != 'free_api';
    try {
      final response = await Api.get(
        url: Api.getLocationApi,
        queryParameters: {
          Api.search: search,
          Api.lang: Constant.currentLanguageCode,
        },
      );

      if (usePaidApi) {
        // final data = await rootBundle.loadString('assets/search_data.json');
        // final response = jsonDecode(data) as Map<String, dynamic>;
        final predictions = (response['data']['predictions'] as List)
            .cast<Map<String, dynamic>>();
        final locations = List<LeafLocation>.empty(growable: true);
        for (final json in predictions) {
          final location = LeafLocation(
            placeId: json['place_id'] as String,
            primaryText: json['structured_formatting']['main_text'] as String,
            secondaryText:
                json['structured_formatting']['secondary_text'] as String?,
          );
          locations.add(location);
        }
        return locations;
      } else {
        final locations = JsonHelper.parseList(
          response['data'] as List?,
          LeafLocation.fromJson,
        );
        return locations;
      }
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'searchLocation');
      log('$stack', name: 'searchLocation');
      throw ApiException(e.toString());
    }
  }

  /// Resolves a [LeafLocation] from the given latitude and longitude.
  ///
  /// Similar to [searchLocation], but uses coordinates instead of text input.
  /// Chooses the appropriate API (paid or free) based on the current map provider.
  ///
  /// Typically used when the user taps "Find My Location" or selects a point on the map.
  Future<LeafLocation> getLocationFromLatLng({
    required double latitude,
    required double longitude,
  }) async {
    final usePaidApi = Constant.mapProvider != 'free_api';
    try {
      final response = await Api.get(
        url: Api.getLocationApi,
        queryParameters: {
          Api.lat: latitude,
          Api.lng: longitude,
          Api.lang: Constant.currentLanguageCode,
        },
      );
      if (usePaidApi) {
        // final data = await rootBundle.loadString('assets/data.json');
        // final response = jsonDecode(data) as Map<String, dynamic>;
        return _extractLeafLocation(
          (response['data']['results'] as List).first,
        );
      } else {
        return JsonHelper.parseJsonOrNull(
              response['data'] as Map<String, dynamic>,
              LeafLocation.fromJson,
            ) ??
            LeafLocation();
      }
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getLocationFromLatLng');
      log('$stack', name: 'getLocationFromLatLng');
      throw ApiException(e.toString());
    }
  }

  /// Retrieves a [LeafLocation] using the provided [placeId] from Google's Places API.
  ///
  /// This method is only available when the paid API is active.
  /// It parses the response and returns a [LeafLocation].
  ///
  /// Throws an error if used with the free API provider.
  Future<LeafLocation> getLocationFromPlaceId({required String placeId}) async {
    try {
      final response = await Api.get(
        url: Api.getLocationApi,
        queryParameters: {
          'place_id': placeId,
          Api.lang: Constant.currentLanguageCode,
        },
      );
      // final data = await rootBundle.loadString('assets/place_id_data.json');
      //final response = jsonDecode(data) as Map<String, dynamic>;
      return _extractLeafLocation((response['data']['results'] as List).first);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getLocationFromPlaceId');
      log('$stack', name: 'getLocationFromPlaceId');
      throw ApiException(e.toString());
    }
  }

  /// Parses a raw JSON response into a [LeafLocation].
  ///
  /// Used internally by [getLocationFromLatLng] and [getLocationFromPlaceId].
  ///
  /// - Stores `latitude`, `longitude`, and `placeId` as-is.
  /// - Extracts location fields based on the following priority:
  ///
  /// **Area**
  ///   1. `sublocality_level_1`
  ///   2. `sublocality`
  ///
  /// **City**
  ///   1. `locality`
  ///   2. `administrative_area_level_3`
  ///
  /// **State**
  ///   - `administrative_area_level_1`
  ///
  /// **Country**
  ///   - `country`
  LeafLocation _extractLeafLocation(Map<String, dynamic> json) {
    final Map<String, dynamic> leafLocationJson = Map.identity();

    leafLocationJson['latitude'] = json['geometry']['location']['lat'];
    leafLocationJson['longitude'] = json['geometry']['location']['lng'];
    leafLocationJson['place_id'] = json['place_id'];

    final components =
        (json['address_components'] as List?)?.cast<Map<String, dynamic>>() ??
        [];
    for (final component in components) {
      final types = (component['types'] as List?)?.cast<String>() ?? [];
      for (final type in types) {
        if (type == 'sublocality_level_1') {
          leafLocationJson['area'] = component['long_name'];
          break;
        } else if (type == 'sublocality' && leafLocationJson['area'] == null) {
          leafLocationJson['area'] = component['long_name'];
          break;
        } else if (type == 'locality' && leafLocationJson['city'] == null) {
          leafLocationJson['city'] = component['long_name'];
          break;
        } else if (type == 'administrative_area_level_3' &&
            leafLocationJson['city'] == null) {
          leafLocationJson['city'] = component['long_name'];
          break;
        } else if (type == 'administrative_area_level_1') {
          leafLocationJson['state'] = component['long_name'];
          break;
        } else if (type == 'country') {
          leafLocationJson['country'] = component['long_name'];
          break;
        }
      }
    }

    return LeafLocation.fromJson(leafLocationJson);
  }
}
