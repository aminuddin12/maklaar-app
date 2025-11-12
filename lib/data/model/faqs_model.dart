import 'package:com.maklaar.app/data/model/localized_string.dart';

class FaqsModel {
  int id;
  LocalizedString question;
  LocalizedString answer;
  String? createdAt;
  String? updatedAt;
  bool isExpanded;

  FaqsModel({
    required this.id,
    required this.question,
    required this.answer,
    this.createdAt,
    this.updatedAt,
    this.isExpanded = false,
  });

  FaqsModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      question = LocalizedString(
        canonical: json['question'],
        translated: json['translated_question'],
      ),
      answer = LocalizedString(
        canonical: json['answer'],
        translated: json['translated_answer'],
      ),
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      isExpanded = json['is_expanded'] ?? false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_expanded'] = isExpanded;
    return data;
  }
}
