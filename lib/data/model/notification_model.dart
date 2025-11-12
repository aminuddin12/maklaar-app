import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/utils/json_helper.dart';

class NotificationData {
  String? id;
  String? title;
  String? message;
  String? image;
  String? type;
  int? sendType;
  String? customersId;
  String? itemsId;
  String? createdAt;
  String? created;
  ItemModel? item;

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    message = json['message'];
    image = json['image'];
    type = json['type'].toString();
    sendType = json['send_type'] as int?;
    customersId = json['customers_id'];
    itemsId = json['items_id'].toString();
    createdAt = json['created_at'];
    created = json['created'];
    // Todo(rio): Refactor this
    item = json['item'] != null
        ? JsonHelper.parseJsonOrNull({
            ...?json['item'] as Json?,
            if (json['item']?['translated_name'] != null)
              'translated_item': {
                'name': ?json['item']?['translated_name'],
                'description': ?json['item']?['translated_description'],
                'city': ?json['item']?['translated_city'],
                'area': ?json['item']?['translated_area'],
                'state': ?json['item']?['translated_state'],
                'country': ?json['item']?['translated_country'],
                'address': ?json['item']?['translated_address'],
              },
          }, ItemModel.fromJson)
        : null;
  }
}
