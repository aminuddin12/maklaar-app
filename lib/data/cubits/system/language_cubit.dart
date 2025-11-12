// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/hive_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  final dynamic language;

  LanguageLoader(this.language);
}

class LanguageLoadFail extends LanguageState {
  final dynamic error;
  LanguageLoadFail({required this.error});
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    var language = Hive.box(
      HiveKeys.languageBox,
    ).get(HiveKeys.currentLanguageKey);
    if (language != null) {
      final languageCode = language?['code'];
      if (languageCode != null && languageCode is String) {
        Constant.currentLanguageCode = languageCode.toUpperCase();
      }
      emit(LanguageLoader(language));
    } else {
      emit(LanguageLoadFail(error: "error"));
    }
  }

  void changeLanguages(dynamic map) {
    Constant.currentLanguageCode = map['code'];
    Constant.currentLocale =
        Constant.countryLocaleMap[map['country_code']
            .toString()
            .toUpperCase()] ??
        'en_US';
    emit(LanguageLoader(map));
  }

  dynamic currentLanguageCode() {
    return Hive.box(
      HiveKeys.languageBox,
    ).get(HiveKeys.currentLanguageKey)['code'];
  }

  dynamic currentLanguageId() {
    return Hive.box(
      HiveKeys.languageBox,
    ).get(HiveKeys.currentLanguageKey)['id'];
  }
}
