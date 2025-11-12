import 'package:com.maklaar.app/data/model/localized_string.dart';

class BlogModel {
  int id;
  LocalizedString title;
  String slug;
  LocalizedString? description;
  String image;
  List<String> tags;
  int? views;
  int? categoryId;
  String? createdAt;
  String? updatedAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.image,
    required this.tags,
    this.views,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  BlogModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      title = LocalizedString(
        canonical: json['title'],
        translated: json['translated_title'],
      ),
      slug = json['slug'] as String,
      description = LocalizedString(
        canonical: json['description'],
        translated: json['translated_description'],
      ),
      image = json['image'] as String,
      tags = json['tags'].cast<String>(),
      views = json['views'],
      categoryId = json['category_id'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['image'] = this.image;
    data['tags'] = this.tags;
    data['views'] = this.views;
    data['category_id'] = this.categoryId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
