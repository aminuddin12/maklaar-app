class CustomFieldModel {
  int? id;
  String? name;
  List? value;
  String? type;
  String? image;
  int? required;
  int? minLength;
  int? maxLength;
  dynamic values;
  String? translatedName;
  List? translatedValue;
  List<dynamic>? translations;

  CustomFieldModel({
    this.id,
    this.name,
    this.type,
    this.values,
    this.image,
    this.required,
    this.maxLength,
    this.minLength,
    this.value,
    this.translatedName,
    this.translatedValue,
    this.translations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'values': values,
      'image': image,
      'required': required,
      'min_length': minLength,
      'max_length': maxLength,
      'value': value,
      'translated_name': translatedName,
      'translated_value': translatedValue,
      'translations': translations,
    };
  }

  factory CustomFieldModel.fromMap(Map<String, dynamic> map) {
    return CustomFieldModel(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      values: map['values'] as dynamic,
      image: map['image'],
      required: map['required'],
      maxLength: map['max_length'],
      minLength: map['min_length'],
      value: map['value'],
      translatedName: map['translated_name'] as String?,
      translatedValue: map['translated_value'] as List?,
      translations: map['translations'] as List<dynamic>?,
    );
  }

  @override
  String toString() {
    return 'CustomFieldModel(id: $id, name: $name, type: $type, image: $image, required: $required, minLength: $minLength, maxLength: $maxLength, values: $values, value: $value, translatedName: $translatedName, translatedValue: $translatedValue, translations: $translations)';
  }
}

class VerificationFieldModel {
  int? id;
  String? name;
  String? translatedName;
  String? type;
  int? required;
  int? minLength;
  int? maxLength;
  String? status;
  dynamic values;
  dynamic translatedValues;

  VerificationFieldModel({
    this.id,
    this.name,
    this.translatedName,
    this.type,
    this.values,
    this.translatedValues,
    this.required,
    this.maxLength,
    this.minLength,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'translated_name': translatedName,
      'type': type,
      'values': values,
      'translated_value': translatedValues,
      'required': required,
      'min_length': minLength,
      'max_length': maxLength,
      'status': status,
    };
  }

  factory VerificationFieldModel.fromMap(Map<String, dynamic> map) {
    return VerificationFieldModel(
      id: map['id'] as int,
      name: map['name'] as String?,
      translatedName: map['translated_name'] as String?,
      type: map['type'] as String,
      values: map['values'] as dynamic,
      translatedValues: map['translated_value'] as dynamic,
      required: map['is_required'],
      maxLength: map['max_length'],
      minLength: map['min_length'],
      status: map['status'],
    );
  }

  @override
  String toString() {
    return 'VerificationFieldModel(id: $id, name: $name, type: $type, required: $required, minLength: $minLength, maxLength: $maxLength, values: $values,status:$status)';
  }
}
