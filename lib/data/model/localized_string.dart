import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/json_helper.dart';

/// Represents a string that supports localization but also stores a canonical fallback.
///
/// - [canonical] is the default or fallback value, typically in English or a known base language.
/// - [localized] is the translated value, usually based on the user's current locale.
///
/// This is especially useful when dealing with server APIs that return localized
/// data based on `Content-Language`, or when you're storing names in Hive without needing
/// a full-blown localization adapter.
///
/// Example:
/// ```dart
/// LocalizedString(canonical: 'India', localized: 'भारत')
/// ```
///
/// The UI can display `.localized ?? .canonical`
/// while APIs will typically only care about `.canonical`.
class LocalizedString {
  LocalizedString({
    required this.canonical,
    Map<String, dynamic> translations = const {},
    String? translated,
  }) : _translations = Map.from(translations) {
    if (translated == null) return;
    this._translations.putIfAbsent(
      Constant.currentLanguageCode.toUpperCase(),
      () => translated,
    );
  }

  LocalizedString.fromJson(Map<String, dynamic> json)
    : canonical = json['canonical'] as String,
      _translations =
          (json['translations'] as Map?)?.cast<String, String>() ?? {};

  factory LocalizedString.fromTranslationsObject({
    required String name,
    required List<Json> translations,
    String? translatedName,
  }) {
    final normalizedTranslations = <String, String>{
      for (final translation in translations)
        ?translation['language']?['code']: ?translation['name'],
    };

    return LocalizedString(
      canonical: name,
      translations: normalizedTranslations,
      translated: translatedName,
    );
  }

  final String canonical;
  final Map<String, String> _translations;

  String get localized {
    final currentLanguageCode = Constant.currentLanguageCode.toUpperCase();
    return _translations[currentLanguageCode] ?? canonical;
  }

  Map<String, dynamic> toJson() => {
    'canonical': canonical,
    'translations': _translations,
  };
}
