typedef Json = Map<String, dynamic>;
typedef FromJson<T> = T Function(Json);

class JsonHelper {
  static T parseObject<T>(Json json, FromJson<T> fromJson) {
    return fromJson.call(json);
  }

  static T? parseJsonOrNull<T>(Json? json, FromJson<T> fromJson) {
    if (json == null) return null;
    return fromJson.call(json);
  }

  static List<T> parseList<T>(List<dynamic>? jsonList, FromJson<T> fromJson) {
    if (jsonList == null || jsonList.isEmpty) return const [];

    if (jsonList.any((element) => element is! Json)) {
      throw FormatException('Expected List<Json>, instead got $jsonList');
    }

    final list = jsonList.cast<Json>().map(fromJson).toList();
    return list;
  }
}
