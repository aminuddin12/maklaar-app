import 'package:com.maklaar.app/data/model/localized_string.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/constant.dart';

/// The final output of the location selection screen for either the free or paid version.
///
/// This DTO contains the necessary data that is passed with the location-aware
/// APIs to fetch data based on user's selected location. The toJson() method of
/// this class is used as parameters for the API calls.
class LeafLocation {
  LeafLocation({
    this.placeId,
    this.area,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.radius,
    this.primaryText,
    this.secondaryText,
  }) {
    _locationParts = [
      ?area?.localized,
      ?city?.localized,
      ?state?.localized,
      ?country?.localized,
    ];
    primaryText ??= _locationParts.firstOrNull;
    secondaryText ??= _locationParts.length > 1
        ? _locationParts.sublist(1).join(', ')
        : null;
  }

  factory LeafLocation.fromJson(Map<String, dynamic> json) => LeafLocation(
    placeId: json['place_id'] as String?,
    area: _parser(json['area'], json['area_translation']),
    city: _parser(json['city'], json['city_translation']),
    state: _parser(json['state'], json['state_translation']),
    country: _parser(json['country'], json['country_translation']),
    latitude: json['latitude'] is double?
        ? json['latitude'] as double?
        : double.tryParse(json['latitude'] as String? ?? ''),
    longitude: json['longitude'] is double?
        ? json['longitude'] as double?
        : double.tryParse(json['longitude'] as String? ?? ''),
    radius: json['radius'] as double? ?? Constant.minRadius,
    primaryText: json['primary_text'] as String?,
    secondaryText: json['secondary_text'] as String?,
  );

  /// Very cursed way of parsing, but there’s historical baggage tied to it.
  ///
  /// TL;DR: The same field may come as:
  /// - a plain `String` (just the canonical value),
  /// - or a `Map<String, String>` with translations (thanks Hive + Free API list).
  ///
  /// Todo(rio): Refactor this once the API contracts are stable.
  static LocalizedString? _parser(dynamic value, String? translatedValue) {
    if (value == null)
      return null;
    else if (value is String) {
      return LocalizedString(canonical: value, translated: translatedValue);
    } else if (value is Map) {
      return LocalizedString.fromJson(Map<String, dynamic>.from(value));
    } else {
      throw Exception('Invalid Type ${value.runtimeType}');
    }
  }

  LeafLocation copyWith({
    double? radius,
    LocalizedString? area,
    LocalizedString? city,
    LocalizedString? state,
    LocalizedString? country,
  }) {
    return LeafLocation(
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
      radius: radius ?? this.radius ?? Constant.minRadius,
    );
  }

  final String? placeId;
  final LocalizedString? area;
  final LocalizedString? city;
  final LocalizedString? state;
  final LocalizedString? country;
  final double? latitude;
  final double? longitude;
  final double? radius;

  late final List<String> _locationParts;

  /// Human-readable name of the current location.
  ///
  /// Returns the name of the most specific available location node.
  String? primaryText;

  /// Hierarchical string representation of the current location path.
  ///
  /// Format: `Area > City > State > Country`, omitting nulls and the primary string.
  String? secondaryText;

  bool get isEmpty => primaryText == null || primaryText!.isEmpty;

  bool get isValid => _locationParts.length >= 3;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasExactPath => hasArea || hasCity;

  String get localizedPath =>
      '$primaryText${secondaryText != null ? ', $secondaryText' : ''}';

  String get canonicalPath => [
    ?area?.canonical,
    ?city?.canonical,
    ?state?.canonical,
    ?country?.canonical,
  ].join(', ');

  bool get hasArea => area != null;

  bool get hasCity => city != null;

  bool get hasState => state != null;

  bool get hasCountry => country != null;

  /// A helper method to pass the location data to the respective APIs conveniently
  Map<String, dynamic> toApiJson() {
    return {
      // Only fetch based on coordinates when city and area is null
      // as using coordinates of state and country will give incorrect results
      if (hasCoordinates && hasExactPath) ...{
        Api.latitude: latitude,
        Api.longitude: longitude,
        Api.radius: radius ?? Constant.minRadius,
      } else ...{
        if (hasArea) Api.area: area!.canonical,
        if (hasCity) Api.city: city!.canonical,
        if (hasState) Api.state: state!.canonical,
        if (hasCountry) Api.country: country!.canonical,
      },
    };
  }

  /// Used to store the object of leaf location to Hive
  /// Different methods because `primary_text` and `secondary_text` are not
  /// concerned with the APIs but we need it for the display purpose
  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    Api.area: area?.toJson(),
    Api.city: city?.toJson(),
    Api.state: state?.toJson(),
    Api.country: country?.toJson(),
    Api.radius: radius,
    Api.latitude: latitude,
    Api.longitude: longitude,
    'primary_text': primaryText,
    'secondary_text': secondaryText,
  };
}
