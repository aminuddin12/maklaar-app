import 'package:com.maklaar.app/data/model/category_model.dart';
import 'package:com.maklaar.app/data/model/custom_field/custom_field_model.dart';
import 'package:com.maklaar.app/data/model/localized_string.dart';
import 'package:com.maklaar.app/data/model/user/seller_ratings_model.dart';

class ItemModel {
  int? id;
  String? name;
  String? slug;
  String? description;
  double? price;
  double? minSalary;
  double? maxSalary;
  String? image;
  dynamic watermarkImage;
  double? _latitude;
  double? _longitude;
  LocalizedString? address;
  String? contact;
  int? totalLikes;
  int? views;
  String? type;
  String? status;
  bool? active;
  String? videoLink;
  User? user;
  List<GalleryImages>? galleryImages;
  List<ItemOffers>? itemOffers;
  CategoryModel? category;
  List<CustomFieldModel>? customFields;
  List<CustomFieldModel>? translatedCustomFields;
  List<dynamic>? translations;
  List<dynamic>? allTranslatedCustomFields;
  Map<String, dynamic>? translatedItem;
  bool? isLike;
  bool? isFeature;
  String? created;
  String? itemType;
  int? userId;
  int? categoryId;
  bool? isAlreadyOffered;
  bool? isAlreadyJobApplied;
  bool? isAlreadyReported;
  String? allCategoryIds;
  String? rejectedReason;
  int? areaId;
  String? area;
  String? city;
  String? state;
  String? country;
  int? isPurchased;
  List<UserRatings>? review;
  int? isEditedByAdmin;
  String? adminEditReason;

  // Translated getters
  String? get translatedName => translatedItem?['name'];

  String? get translatedDescription => translatedItem?['description'];

  String? get translatedAddress => address?.localized;

  String? get translatedRejectedReason => translatedItem?['rejected_reason'];

  String? get translatedAdminEditReason => translatedItem?['admin_edit_reason'];

  double? get latitude => _latitude;

  set latitude(dynamic value) {
    if (value is int) {
      _latitude = value.toDouble();
    } else if (value is double) {
      _latitude = value;
    } else {
      _latitude = null;
    }
  }

  double? get longitude => _longitude;

  set longitude(dynamic value) {
    if (value is int) {
      _longitude = value.toDouble();
    } else if (value is double) {
      _longitude = value;
    } else {
      _longitude = null;
    }
  }

  ItemModel.fromJson(Map<String, dynamic> json) {
    if (json['area'] != null) {
      areaId = json['area']['id'];
      area = json['area']['name'];
    }
    if (json['price'] is int) {
      price = (json['price'] as int).toDouble();
    } else {
      price = json['price'];
    }
    if (json['min_salary'] is int) {
      minSalary = (json['min_salary'] as int).toDouble();
    } else {
      minSalary = json['min_salary'];
    }
    if (json['max_salary'] is int) {
      maxSalary = (json['max_salary'] as int).toDouble();
    } else {
      maxSalary = json['max_salary'];
    }
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    totalLikes = json['total_likes'];
    views = json['clicks'];
    description = json['description'];
    image = json['image'];
    watermarkImage = json['watermark_image'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'] != null
        ? LocalizedString(
            canonical: json['address'],
            translated: json['translated_address'],
          )
        : null;
    contact = json['contact'];
    type = json['type'];
    status = json['status'];
    active = json['active'] == 0 ? false : true;
    videoLink = json['video_link'];
    isLike = json['is_liked'];
    isFeature = json['is_feature'];
    created = json['created_at'];
    itemType = json['item_type'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    isAlreadyOffered = json['is_already_offered'];
    isAlreadyJobApplied = json['is_already_job_applied'];
    isAlreadyReported = json['is_already_reported'];
    allCategoryIds = json['all_category_ids'];
    rejectedReason = json['rejected_reason'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    isPurchased = json['is_purchased'];
    isEditedByAdmin = json['is_edited_by_admin'];
    adminEditReason = json['admin_edit_reason'];
    translations = json['translations'];
    translatedItem = json['translated_item'] ?? {};
    allTranslatedCustomFields = json['all_translated_custom_fields'];
    if (json['review'] != null) {
      review = <UserRatings>[];
      json['review'].forEach((v) {
        review!.add(UserRatings.fromJson(v));
      });
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['gallery_images'] != null) {
      galleryImages = <GalleryImages>[];
      json['gallery_images'].forEach((v) {
        galleryImages!.add(GalleryImages.fromJson(v));
      });
    }
    if (json['item_offers'] != null) {
      itemOffers = <ItemOffers>[];
      json['item_offers'].forEach((v) {
        itemOffers!.add(ItemOffers.fromJson(v));
      });
    }
    if (json['custom_fields'] != null) {
      customFields = <CustomFieldModel>[];
      json['custom_fields'].forEach((v) {
        customFields!.add(CustomFieldModel.fromMap(v));
      });
    }
    if (json['translated_custom_fields'] != null) {
      translatedCustomFields = <CustomFieldModel>[];
      json['translated_custom_fields'].forEach((v) {
        translatedCustomFields!.add(CustomFieldModel.fromMap(v));
      });
    }
    /* if (json['translated_item'] != null) {
      translatedItem = Map<String, dynamic>.from(json['translated_item']);
    }*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['price'] = price;
    data['min_salary'] = minSalary;
    data['max_salary'] = maxSalary;
    data['total_likes'] = totalLikes;
    data['clicks'] = views;
    data['image'] = image;
    data['watermark_image'] = watermarkImage;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address?.canonical;
    data['contact'] = contact;
    data['type'] = type;
    data['status'] = status;
    data['active'] = active;
    data['video_link'] = videoLink;
    data['is_liked'] = isLike;
    data['is_feature'] = isFeature;
    data['created_at'] = created;
    data['item_type'] = itemType;
    data['user_id'] = userId;
    data['category_id'] = categoryId;
    data['is_already_offered'] = isAlreadyOffered;
    data['is_already_job_applied'] = isAlreadyJobApplied;
    data['is_already_reported'] = isAlreadyReported;
    data['all_category_ids'] = allCategoryIds;
    data['rejected_reason'] = rejectedReason;
    data['admin_edit_reason'] = adminEditReason;
    data['is_purchased'] = isPurchased;
    data['is_edited_by_admin'] = isEditedByAdmin;
    if (review != null) {
      data['review'] = review!.map((v) => v.toJson()).toList();
    }
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['category'] = category!.toJson();
    if (areaId != null && area != null) {
      data['area'] = {'id': areaId, 'name': area};
    }
    data['user'] = user!.toJson();
    if (galleryImages != null) {
      data['gallery_images'] = galleryImages!.map((v) => v.toJson()).toList();
    }
    if (itemOffers != null) {
      data['item_offers'] = itemOffers!.map((v) => v.toJson()).toList();
    }
    if (customFields != null) {
      data['custom_fields'] = customFields!.map((v) => v.toMap()).toList();
    }
    if (translatedCustomFields != null) {
      data['translated_custom_fields'] = translatedCustomFields!
          .map((v) => v.toMap())
          .toList();
    }
    if (translations != null) {
      data['translations'] = translations;
    }
    if (allTranslatedCustomFields != null) {
      data['all_translated_custom_fields'] = allTranslatedCustomFields;
    }
    if (translatedItem != null) {
      data['translated_item'] = translatedItem;
    }
    return data;
  }

  @override
  String toString() {
    return 'ItemModel{id: $id, name: $name,slug:$slug, description: $description, price: $price, image: $image, watermarkImage: $watermarkImage, latitude: $latitude, longitude: $longitude, address: ${address?.localized}, contact: $contact, total_likes: $totalLikes,isLiked: $isLike, isFeature: $isFeature,views: $views, type: $type, status: $status, active: $active, videoLink: $videoLink, user: $user, galleryImages: $galleryImages,itemOffers:$itemOffers, category: $category, customFields: $customFields,translatedCustomFields:$translatedCustomFields,translations:$translations,allTranslatedCustomFields:$allTranslatedCustomFields,createdAt:$created,itemType:$itemType,userId:$userId,categoryId:$categoryId,isAlreadyOffered:$isAlreadyOffered,isAlreadyJobApplied:$isAlreadyJobApplied,isAlreadyReported:$isAlreadyReported,allCategoryId:$allCategoryIds,rejected_reason:$rejectedReason,area_id:$areaId,area:$area,city:$city,state:$state,country:$country,is_purchased:$isPurchased,review:$review,minSalary:$minSalary,maxSalary:$maxSalary,isEditedByAdmin: $isEditedByAdmin,adminEditReason:$adminEditReason,translatedItem:$translatedItem}';
  }
}

class User {
  int? id;
  String? name;
  String? mobile;
  String? email;
  String? type;
  String? profile;
  String? fcmId;
  String? firebaseId;
  int? status;
  String? apiToken;
  dynamic address;
  String? createdAt;
  String? updatedAt;
  int? showPersonalDetails;
  int? isVerified;

  User({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.type,
    this.profile,
    this.fcmId,
    this.firebaseId,
    this.status,
    this.apiToken,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.isVerified,
    this.showPersonalDetails,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    type = json['type'];
    profile = json['profile'];
    fcmId = json['fcm_id'];
    firebaseId = json['firebase_id'];
    status = json['status'];
    apiToken = json['api_token'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isVerified = json['is_verified'];
    showPersonalDetails = json['show_personal_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['email'] = email;
    data['type'] = type;
    data['profile'] = profile;
    data['fcm_id'] = fcmId;
    data['firebase_id'] = firebaseId;
    data['status'] = status;
    data['api_token'] = apiToken;
    data['address'] = address;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_verified'] = isVerified;
    data['show_personal_details'] = showPersonalDetails;
    return data;
  }
}

class GalleryImages {
  int? id;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? itemId;

  GalleryImages({
    this.id,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.itemId,
  });

  GalleryImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemId = json['item_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_id'] = itemId;
    return data;
  }
}

class ItemOffers {
  int? id;
  int? sellerId;
  int? buyerId;
  String? createdAt;
  String? updatedAt;
  double? amount;

  ItemOffers({
    this.id,
    this.sellerId,
    this.createdAt,
    this.updatedAt,
    this.buyerId,
    this.amount,
  });

  ItemOffers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buyerId = json['buyer_id'];
    sellerId = json['seller_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    // Handle amount being int or double
    if (json['amount'] is int) {
      amount = (json['amount'] as int).toDouble();
    } else if (json['amount'] is double) {
      amount = json['amount'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['buyer_id'] = buyerId;
    data['seller_id'] = sellerId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['amount'] = amount;
    return data;
  }
}
