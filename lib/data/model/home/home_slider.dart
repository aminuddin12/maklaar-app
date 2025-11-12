import 'package:com.maklaar.app/data/model/localized_string.dart';

class HomeSlider {
  int? id;
  String? sequence;
  String? thirdPartyLink;
  String? modelType;
  String? image;
  int? modelId;
  CategorySlider? model;

  HomeSlider({
    this.id,
    this.sequence,
    this.thirdPartyLink,
    this.modelId,
    this.image,
    this.modelType,
    this.model,
  });

  HomeSlider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequence = json['sequence'];
    thirdPartyLink = json['third_party_link'];
    modelId = json['model_id'];
    image = json['image'];
    modelType = json['model_type'];
    if (json['model'] != null &&
        modelType != null &&
        modelType!.contains("Category")) {
      model = CategorySlider.fromJson(json['model']);
    } else {
      model = null;
    }
  }
}

class CategorySlider {
  int? id;
  LocalizedString? name;
  int? subCategoriesCount;
  int? parentCategoryId;

  CategorySlider({
    this.id,
    this.name,
    this.subCategoriesCount,
    this.parentCategoryId,
  });

  CategorySlider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = LocalizedString(
      canonical: json['name'],
      translated: json['translated_name'],
    );
    subCategoriesCount = json['subcategories_count'];
    parentCategoryId = json['parent_category_id'];
  }
}
