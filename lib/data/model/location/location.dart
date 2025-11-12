import 'package:com.maklaar.app/data/cubits/location/location_cubit.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/model/location/location_node.dart';
import 'package:com.maklaar.app/utils/constant.dart';

/// This DTO is internally used and managed by [LocationCubit] to keep track of
/// current location selection path. It also aids in the visuals of [LocationScreen]
/// to show the current location path
///
/// This class should not be used anywhere else except [LocationCubit] and [LocationScreen]
///
/// See [LeafLocation] for usage elsewhere in the app
class Location {
  Location({this.country, this.state, this.city, this.area});

  factory Location.empty() => Location();

  final Country? country;
  final State? state;
  final City? city;
  final Area? area;

  /// Retrieves the current hierarchy node of the location selection.
  /// Used to fetch more data from the API without passing around IDs.
  LocationNode? get lastNode => [?country, ?state, ?city, ?area].lastOrNull;

  bool get isEmpty => country == null;

  Location copyWith({Country? country, State? state, City? city, Area? area}) =>
      Location(country: country, state: state, city: city, area: area);
}

/// A helper extension on [Location] that converts logical [Location] object into
/// a useful [LeafLocation] object for app-wide usage
extension LocationToLeaf on Location {
  LeafLocation toLeafLocation() => LeafLocation(
    area: area?.name,
    city: city?.name,
    state: state?.name,
    country: country?.name,
    latitude: double.tryParse(lastNode?.latitude ?? ''),
    longitude: double.tryParse(lastNode?.longitude ?? ''),
    radius: Constant.minRadius,
  );
}
