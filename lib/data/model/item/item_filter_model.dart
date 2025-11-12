import 'package:com.maklaar.app/data/model/location/leaf_location.dart';

class ItemFilterModel {
  final String? maxPrice;
  final String? minPrice;
  final String? categoryId;
  final String? postedSince;
  final LeafLocation? location;
  final Map<String, dynamic>? customFields;

  ItemFilterModel({
    this.maxPrice,
    this.minPrice,
    this.categoryId,
    this.postedSince,
    this.location,
    this.customFields = const {},
  });

  ItemFilterModel copyWith({
    String? maxPrice,
    String? minPrice,
    String? categoryId,
    String? postedSince,
    String? city,
    String? state,
    String? country,
    String? area,
    int? areaId,
    int? radius,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? customFields,
  }) {
    return ItemFilterModel(
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      categoryId: categoryId ?? this.categoryId,
      postedSince: postedSince ?? this.postedSince,

      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'max_price': maxPrice,
      'min_price': minPrice,
      'category_id': categoryId,
      'posted_since': postedSince,
      ...?location?.toApiJson(),
    };
  }
}
