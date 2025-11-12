import 'package:com.maklaar.app/utils/custom_exception.dart';
import 'package:com.maklaar.app/settings.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SettingsPagesState {}



class SettingsPagesInitial extends SettingsPagesState {}

class SettingsPagesFetchProgress extends SettingsPagesState {}

class SettingsPagesFetchSuccess extends SettingsPagesState {
  String data;
  SettingsPagesFetchSuccess({required this.data});

  Map<String, dynamic> toMap() {
    return {
      'data': data,
    };
  }

  factory SettingsPagesFetchSuccess.fromMap(Map<String, dynamic> map) {
    return SettingsPagesFetchSuccess(
      data: map['data'] as String,
    );
  }
}

class SettingsPagesFetchFailure extends SettingsPagesState {
  final String errMsg;
  SettingsPagesFetchFailure(this.errMsg);
}

class SettingsPagesCubit extends Cubit<SettingsPagesState> {
  SettingsPagesCubit() : super(SettingsPagesInitial());

  void fetchSettingsPages(BuildContext context, String title,
      {bool? forceRefresh}) async {
    if (forceRefresh != true) {
      if (state is SettingsPagesFetchSuccess) {
        await Future.delayed(
            const Duration(seconds: AppSettings.hiddenAPIProcessDelay));
      } else {
        emit(SettingsPagesFetchProgress());
      }
    } else {
      emit(SettingsPagesFetchProgress());
    }

    if (forceRefresh == true) {
      fetchSettingsPagesFromDb(context, title).then((value) {
        emit(SettingsPagesFetchSuccess(data: value ?? ""));
      }).catchError((e, stack) {
        emit(SettingsPagesFetchFailure(stack.toString()));
      });
    } else {
      if (state is! SettingsPagesFetchSuccess) {
        fetchSettingsPagesFromDb(context, title).then((value) {
          emit(SettingsPagesFetchSuccess(data: value ?? ""));
        }).catchError((e, stack) {
          emit(SettingsPagesFetchFailure(stack.toString()));
        });
      } else {
        emit(
          SettingsPagesFetchSuccess(
            data: (state as SettingsPagesFetchSuccess).data,
          ),
        );
      }
    }
  }

  Future<String?> fetchSettingsPagesFromDb(
      BuildContext context, String title) async {
    try {
      String? settingsPagesData;
      Map<String, String> body = {
        Api.type: title,
      };

      var response = await Api.get(
        url: Api.getSystemSettingsApi,
        queryParameters: body,
      );

      if (!response[Api.error]) {

        if (title == Api.maintenanceMode) {
          Constant.maintenanceMode = response['data'].toString();
        } else {
          Map data = (response['data']);

          if (title == Api.termsAndConditions) {
            settingsPagesData = data['terms_conditions'];

          }

          if (title == Api.privacyPolicy) {
            settingsPagesData = data['privacy_policy'];

          }

          if (title == Api.aboutUs) {
            settingsPagesData = data['about_us'];

          }

          if (title == Api.contactUs) {
            settingsPagesData = data['contact_us'];

          }
        }
      } else {
        throw CustomException(response[Api.message]);
      }

      return settingsPagesData;
    } catch (e) {
      rethrow;
    }
  }

}
