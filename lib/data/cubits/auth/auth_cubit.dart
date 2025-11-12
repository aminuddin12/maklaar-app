import 'dart:io';

import 'package:dio/dio.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for all authentication states
abstract class AuthState {
  const AuthState();
}

/// Initial authentication state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication in progress state
class AuthProgress extends AuthState {
  const AuthProgress();
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authenticated state with authentication status
class Authenticated extends AuthState {
  final bool isAuthenticated;

  const Authenticated(this.isAuthenticated);
}

/// Authentication failure state with error message
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);
}

/// Cubit for handling authentication logic
class AuthCubit extends Cubit<AuthState> {
  /// Creates a new instance of [AuthCubit]
  AuthCubit() : super(const AuthInitial());

  /// Checks if the user is authenticated and emits appropriate state
  void checkIsAuthenticated() {
    try {
      final isAuthenticated = HiveUtils.isUserAuthenticated();
      emit(Authenticated(isAuthenticated));
    } catch (e) {
      emit(AuthFailure('Failed to check authentication status: $e'));
    }
  }

  /// Updates user profile data
  ///
  /// Returns a [Map] containing the API response
  /// Throws an exception if the update fails
  Future<Map<String, dynamic>> updateUserData(
    BuildContext context, {
    String? name,
    String? email,
    String? address,
    File? fileUserImg,
    String? fcmToken,
    String? notification,
    String? mobile,
    String? countryCode,
    int? personalDetail,
  }) async {
    try {
      emit(const AuthProgress());

      final parameters = await _buildUpdateParameters(
        name: name,
        email: email,
        address: address,
        fileUserimg: fileUserImg,
        fcmToken: fcmToken,
        notification: notification,
        mobile: mobile,
        countryCode: countryCode,
        personalDetail: personalDetail,
      );

      final response = await Api.post(
        url: Api.updateProfileApi,
        parameter: parameters,
      );

      if (!response[Api.error]) {
        HiveUtils.setUserData(response['data']);
        emit(Authenticated(true));
      } else {
        emit(Unauthenticated());
      }

      return response;
    } catch (e) {
      emit(AuthFailure('Failed to update profile: $e'));
      rethrow;
    }
  }

  /// Builds the parameters map for profile update
  Future<Map<String, dynamic>> _buildUpdateParameters({
    String? name,
    String? email,
    String? address,
    File? fileUserimg,
    String? fcmToken,
    String? notification,
    String? mobile,
    String? countryCode,
    int? personalDetail,
  }) async {
    final parameters = {
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      Api.notification: notification,
      Api.mobile: mobile,
      Api.countryCode: countryCode,
      Api.personalDetail: personalDetail,
    };

    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }

    return parameters;
  }

  /// Signs out the current user
  Future<void> signOut(BuildContext context) async {
    try {
      if (state is Authenticated) {
        emit(const AuthProgress());
        HiveUtils.logoutUser(context, onLogout: () {});
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthFailure('Failed to sign out: $e'));
    }
  }
}
