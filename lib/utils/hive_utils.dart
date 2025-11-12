import 'package:com.maklaar.app/app/app_theme.dart';
import 'package:com.maklaar.app/app/routes.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/model/user/user_model.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static String getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void dontShowChooseLocationDialog() {
    Hive.box(HiveKeys.userDetailsBox).put("showChooseLocationDialoge", false);
  }

  static bool isShowChooseLocationDialog() {
    var value = Hive.box(
      HiveKeys.userDetailsBox,
    ).get("showChooseLocationDialoge");
    return value == null;
  }

  static String? getUserId() {
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static AppTheme getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    return current == "dark" ? AppTheme.dark : AppTheme.light;
  }

  static String? getCountryCode() {
    return Hive.box(HiveKeys.userDetailsBox).get("country_code");
  }

  static void setProfileNotCompleted() async {
    await Hive.box(
      HiveKeys.userDetailsBox,
    ).put(HiveKeys.isProfileCompleted, false);
  }

  static dynamic setCurrentTheme(AppTheme theme) {
    String newTheme = theme == AppTheme.light ? "light" : "dark";

    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getNearbyRadius() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.nearbyRadius);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getAreaName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.area);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getCountryName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getLatitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.latitudeKey);
  }

  @Deprecated('Use getLocationV2() instead')
  static dynamic getLongitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.longitudeKey);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
      Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()),
    );
  }

  static void setUserIsAuthenticated(bool value) {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, value);
  }

  static Future<void> setUserIsNotNew() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static Future<void> setUserSkip() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserSkip, true);
  }

  @Deprecated('Use setLocationV2() instead')
  static void setCurrentLocation({
    required String city,
    required String state,
    required String country,
    latitude,
    longitude,
    String? area,
  }) async {
    if (Constant.isDemoModeOn) {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.currentLocationCity: "Bhuj",
        HiveKeys.currentLocationState: "Gujarat",
        HiveKeys.currentLocationCountry: "India",
        HiveKeys.currentLocationArea: null,
        HiveKeys.currentLocationLatitude: 23.2533,
        HiveKeys.currentLocationLongitude: 69.6693,
      });
    } else {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.currentLocationCity: city,
        HiveKeys.currentLocationState: state,
        HiveKeys.currentLocationCountry: country,
        HiveKeys.currentLocationLatitude: latitude,
        HiveKeys.currentLocationLongitude: longitude,
        HiveKeys.currentLocationArea: area,
      });
    }
  }

  static void clearLocation() async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: null,
      HiveKeys.stateKey: null,
      HiveKeys.countryKey: null,
      HiveKeys.areaId: null,
      HiveKeys.area: null,
      HiveKeys.latitudeKey: null,
      HiveKeys.longitudeKey: null,
      HiveKeys.nearbyRadius: null,
      HiveKeys.currentLocationCity: null,
      HiveKeys.currentLocationState: null,
      HiveKeys.currentLocationCountry: null,
      HiveKeys.currentLocationArea: null,
      HiveKeys.currentLocationLatitude: null,
      HiveKeys.currentLocationLongitude: null,
    });
  }

  static void setLocationV2({required LeafLocation location}) {
    final effectiveLocation = Constant.isDemoModeOn
        ? Constant.defaultLocation
        : location;
    Hive.box(
      HiveKeys.userDetailsBox,
    ).put(HiveKeys.locationKey, effectiveLocation.toJson());

    // For backwards compatibility
    Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.area: effectiveLocation.area?.canonical,
      HiveKeys.city: effectiveLocation.city?.canonical,
      HiveKeys.stateKey: effectiveLocation.state?.canonical,
      HiveKeys.countryKey: effectiveLocation.country?.canonical,
      HiveKeys.latitudeKey: effectiveLocation.latitude,
      HiveKeys.longitudeKey: effectiveLocation.longitude,
      HiveKeys.nearbyRadius: effectiveLocation.radius,
    });
  }

  static LeafLocation? getLocationV2() {
    final json =
        (Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.locationKey) as Map?)
            ?.cast<String, dynamic>();

    return json != null ? LeafLocation.fromJson(json) : null;
  }

  static Future<bool> storeLanguage(dynamic data) async {
    Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, data);
    return true;
  }

  static dynamic getLanguage() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }

  @visibleForTesting
  static Future<void> setUserIsNew() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static bool isUserSkip() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserSkip) ?? false;
  }

  static Future<void> logoutUser(
    context, {
    required VoidCallback onLogout,
    bool? isRedirect,
  }) async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    HiveUtils.setUserIsAuthenticated(false);

    onLogout.call();

    Future.delayed(Duration.zero, () {
      if (isRedirect ?? true) {
        HelperUtils.killPreviousPages(context, Routes.login, {});
      }
    });
  }

  static Future<void> clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    await Hive.box(HiveKeys.historyBox).clear();
    HiveUtils.setUserIsAuthenticated(false);
  }
}
