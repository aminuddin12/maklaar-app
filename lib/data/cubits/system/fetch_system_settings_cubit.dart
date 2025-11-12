import 'dart:developer';

import 'package:com.maklaar.app/data/model/system_settings_model.dart';
import 'package:com.maklaar.app/data/repositories/system_repository.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/network/network_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for system settings
abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final Map settings;

  FetchSystemSettingsSuccess({required this.settings});

  Map<String, dynamic> toMap() => {'settings': settings};

  factory FetchSystemSettingsSuccess.fromMap(Map<String, dynamic> map) =>
      FetchSystemSettingsSuccess(settings: map['settings'] as Map);
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

/// Cubit responsible for managing system settings
class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());

  final SystemRepository _systemRepository = SystemRepository();

  /// Fetches system settings
  ///
  /// [forceRefresh] - If true, forces a refresh of the settings
  Future<void> fetchSettings({bool? forceRefresh}) async {
    try {
      if (!_shouldFetch(forceRefresh)) return;

      emit(FetchSystemSettingsInProgress());

      if (forceRefresh ?? false || state is! FetchSystemSettingsSuccess) {
        await _fetchAndUpdateSettings();
      } else {
        await _checkInternetAndUpdateSettings();
      }
    } catch (e, st) {
      log('$st');
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  /// Determines if the fetch operation should proceed
  bool _shouldFetch(bool? forceRefresh) {
    if (forceRefresh == true) return true;
    if (state is FetchSystemSettingsSuccess) {
      return false;
    }
    return true;
  }

  /// Fetches and updates system settings
  Future<void> _fetchAndUpdateSettings() async {
    try {
      final settings = await _systemRepository.fetchSystemSettings();
      _updateConstants(settings);
      emit(FetchSystemSettingsSuccess(settings: settings));
    } on Exception catch (e, st) {
      log('$st');
    }
  }

  /// Checks internet connection and updates settings accordingly
  Future<void> _checkInternetAndUpdateSettings() async {
    await CheckInternet.check(
      onInternet: () async {
        await _fetchAndUpdateSettings();
      },
      onNoInternet: () {
        if (state is FetchSystemSettingsSuccess) {
          emit(
            FetchSystemSettingsSuccess(
              settings: (state as FetchSystemSettingsSuccess).settings,
            ),
          );
        }
      },
    );
  }

  /// Updates all constant values from settings
  void _updateConstants(Map settings) {
    Constant.otpServiceProvider = _getSetting(
      settings,
      SystemSetting.otpServiceProvider,
    );
    Constant.mapProvider = _getSetting(settings, SystemSetting.mapProvider);
    Constant.currencySymbol = _getSetting(
      settings,
      SystemSetting.currencySymbol,
    );
    Constant.currencyPositionIsLeft =
        _getSetting(settings, SystemSetting.currencySymbolPosition) == 'left';
    Constant.maintenanceMode = _getSetting(
      settings,
      SystemSetting.maintenanceMode,
    );

    // Ad settings
    _updateAdSettings(settings);

    // Location settings
    Constant.defaultLatitude =
        _getSetting(settings, SystemSetting.defaultLatitude) ?? "";
    Constant.defaultLongitude =
        _getSetting(settings, SystemSetting.defaultLongitude) ?? "";

    // Store URLs
    _updateStoreUrls(settings);

    // Authentication settings
    _updateAuthenticationSettings(settings);

    // Radius settings
    Constant.minRadius = double.parse(
      _getSetting(settings, SystemSetting.minRadius) ?? "0",
    );
    Constant.maxRadius = double.parse(
      _getSetting(settings, SystemSetting.maxRadius) ?? "0",
    );
    Constant.autoApproveEditedItem =
        _getSetting(settings, SystemSetting.autoApproveEditedItem) ?? "0";
  }

  /// Updates ad-related settings
  void _updateAdSettings(Map settings) {
    Constant.isGoogleBannerAdsEnabled =
        _getSetting(settings, SystemSetting.bannerAdStatus) ?? "";
    Constant.isGoogleInterstitialAdsEnabled =
        _getSetting(settings, SystemSetting.interstitialAdStatus) ?? "";
    Constant.isGoogleNativeAdsEnabled =
        _getSetting(settings, SystemSetting.nativeAdStatus) ?? "";

    Constant.bannerAdIdAndroid =
        _getSetting(settings, SystemSetting.bannerAdAndroidAd) ?? "";
    Constant.bannerAdIdIOS =
        _getSetting(settings, SystemSetting.bannerAdiOSAd) ?? "";
    Constant.interstitialAdIdAndroid =
        _getSetting(settings, SystemSetting.interstitialAdAndroidAd) ?? "";
    Constant.interstitialAdIdIOS =
        _getSetting(settings, SystemSetting.interstitialAdiOSAd) ?? "";
    Constant.nativeAdIdAndroid =
        _getSetting(settings, SystemSetting.nativeAndroidAd) ?? "";
    Constant.nativeAdIdIOS =
        _getSetting(settings, SystemSetting.nativeAdiOSAd) ?? "";
  }

  /// Updates store URLs and iOS app ID
  void _updateStoreUrls(Map settings) {
    Constant.playStoreUrl =
        _getSetting(settings, SystemSetting.playStoreLink) ?? "";
    Constant.appStoreUrl =
        _getSetting(settings, SystemSetting.appStoreLink) ?? "";
    Constant.iOSAppId =
        (_getSetting(settings, SystemSetting.appStoreLink) ?? "")
            .toString()
            .split('/')
            .last;
  }

  /// Updates authentication-related settings
  void _updateAuthenticationSettings(Map settings) {
    Constant.mobileAuthentication =
        _getSetting(settings, SystemSetting.mobileAuthentication) ?? "0";
    Constant.googleAuthentication =
        _getSetting(settings, SystemSetting.googleAuthentication) ?? "0";
    Constant.appleAuthentication =
        _getSetting(settings, SystemSetting.appleAuthentication) ?? "0";
    Constant.emailAuthentication =
        _getSetting(settings, SystemSetting.emailAuthentication) ?? "0";
  }

  /// Gets a specific setting value
  dynamic getSetting(SystemSetting selected) {
    if (state is! FetchSystemSettingsSuccess) return null;

    final settings = (state as FetchSystemSettingsSuccess).settings['data'];

    if (selected == SystemSetting.subscription) {
      return settings['subscription'] == true
          ? settings['package']['user_purchased_package'] as List
          : [];
    }

    if (selected == SystemSetting.language) {
      return (settings['languages'] as List);
    }

    if (selected == SystemSetting.demoMode) {
      return settings.containsKey("demo_mode") ? settings['demo_mode'] : false;
    }

    return settings[Constant.systemSettingKeys[selected]];
  }

  /// Gets raw settings data
  Map getRawSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings['data'];
    }
    return {};
  }

  /// Gets a setting value from the settings map
  dynamic _getSetting(Map settings, SystemSetting selected) =>
      settings['data'][Constant.systemSettingKeys[selected]] ?? '';
}
