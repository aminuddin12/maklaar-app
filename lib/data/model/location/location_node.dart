import 'package:com.maklaar.app/data/model/localized_string.dart';
import 'package:com.maklaar.app/utils/json_helper.dart';

/// Base class to hold the mandatory data properties for all its children
base class LocationNode {
  LocationNode.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = LocalizedString.fromTranslationsObject(
        name: json['name'] as String,
        translations: JsonHelper.parseList(
          json['translations'] as List?,
          (json) => json,
        ),
        translatedName: json['translated_name'] as String?,
      ),
      latitude = json['latitude'] as String? ?? '0.0',
      longitude = json['longitude'] as String? ?? '0.0';

  final int id;
  final LocalizedString name;
  final String latitude;
  final String longitude;
}

/// Country class has no additional data property or methods
final class Country extends LocationNode {
  Country.fromJson(super.json) : super.fromJson();
}

/// State class have a reference to its hierarchical parent, i.e., country, in form of `countryId`,
/// in addition to the properties of [LocationNode]
final class State extends LocationNode {
  State.fromJson(super.json)
    : countryId = json['country_id'] as int,
      super.fromJson();
  final int countryId;
}

/// City class have a reference to its hierarchical parents, i.e., state and country
/// in form of `stateId` and `countryId`, respectively, in addition to the properties of [LocationNode]
final class City extends LocationNode {
  City.fromJson(super.json)
    : stateId = json['state_id'] as int,
      countryId = json['country_id'] as int,
      super.fromJson();
  final int stateId;
  final int countryId;
}

/// Area class have a reference to its hierarchical parents, i.e., city, state and country
/// in form of `cityId`, `stateId` and `countryId`, respectively, in addition to the properties of [LocationNode]
final class Area extends LocationNode {
  Area.fromJson(super.json)
    : cityId = json['city_id'] as int,
      stateId = json['state_id'] as int,
      countryId = json['country_id'] as int,
      super.fromJson();

  final int cityId;
  final int stateId;
  final int countryId;
}
