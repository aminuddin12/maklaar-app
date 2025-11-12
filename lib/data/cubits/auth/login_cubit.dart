import 'dart:io';

import 'package:com.maklaar.app/data/cubits/auth/authentication_cubit.dart';
import 'package:com.maklaar.app/data/repositories/auth_repository.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for the login operation
abstract class LoginState {
  const LoginState();
}

/// Initial state when no login operation has been performed
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State indicating that the login operation is in progress
class LoginInProgress extends LoginState {
  const LoginInProgress();
}

/// State indicating successful login
class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  final dynamic credential;
  final Map<String, dynamic> apiResponse;

  const LoginSuccess({
    required this.isProfileCompleted,
    required this.credential,
    required this.apiResponse,
  });
}

/// State indicating failure in login
class LoginFailure extends LoginState {
  final dynamic errorMessage;

  const LoginFailure(this.errorMessage);
}

/// Cubit responsible for handling login operations
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;

  /// Creates a new instance of [LoginCubit]
  LoginCubit({
    AuthRepository? authRepository,
    FirebaseAuth? firebaseAuth,
    FirebaseMessaging? firebaseMessaging,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        super(const LoginInitial());

  /// Gets the device token for push notifications
  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        return await _firebaseMessaging.getAPNSToken();
      }
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Handles the login process
  Future<void> login({
    String? phoneNumber,
    required String firebaseUserId,
    required String type,
    required UserCredential credential,
    String? countryCode,
  }) async {
    try {
      emit(const LoginInProgress());

      final token = await _getFCMToken();
      final user = await _getUpdatedUser(type, credential);
      final name = _getUserName(type, user, credential);

      final result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber ?? credential.user!.providerData[0].phoneNumber,
        type: type,
        uid: firebaseUserId,
        fcmId: token,
        email: credential.user!.providerData[0].email,
        name: name,
        profile: credential.user!.providerData[0].photoURL,
        countryCode: countryCode,
      );

      await _handleLoginResponse(result, credential);
    } catch (e) {
      emit(LoginFailure(e));
    }
  }

  /// Handles login with Twilio
  Future<void> loginWithTwilio({
    required String phoneNumber,
    required String firebaseUserId,
    required String type,
    required Map<String, dynamic> credential,
    required String countryCode,
  }) async {
    try {
      emit(const LoginInProgress());
      final token = await _getFCMToken();

      if (_isValidTwilioCredential(credential)) {
        await _handleTwilioLoginResponse(credential);
        return;
      }

      final result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber,
        type: type,
        uid: firebaseUserId,
        fcmId: token,
        email: null,
        name: null,
        profile: null,
        countryCode: countryCode,
      );

      await _handleLoginResponse(result, credential);
    } catch (e) {
      emit(LoginFailure(e));
    }
  }

  /// Gets FCM token with error handling
  Future<String?> _getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (_) {
      return '';
    }
  }

  /// Gets updated user information
  Future<User?> _getUpdatedUser(String type, UserCredential credential) async {
    if (type == AuthenticationType.apple.name) {
      final user = _firebaseAuth.currentUser;
      await credential.user!.reload();
      return user;
    }
    return null;
  }

  /// Gets user name based on authentication type
  String? _getUserName(String type, User? updatedUser, UserCredential credential) {
    if (type == AuthenticationType.apple.name) {
      return updatedUser?.displayName ??
          credential.user!.displayName ??
          credential.user!.providerData[0].displayName;
    }
    return credential.user!.providerData[0].displayName;
  }

  /// Handles login response
  Future<void> _handleLoginResponse(
    Map<String, dynamic> result,
    dynamic credential,
  ) async {
    HiveUtils.setJWT(result['token']);
    final data = result['data'];
    final isProfileCompleted = _isProfileCompleted(data);

    if (!isProfileCompleted) {
      HiveUtils.setProfileNotCompleted();
    }

    HiveUtils.setUserData(data);
    emit(LoginSuccess(
      apiResponse: Map<String, dynamic>.from(data),
      isProfileCompleted: isProfileCompleted,
      credential: credential,
    ));
  }

  /// Handles Twilio login response
  Future<void> _handleTwilioLoginResponse(Map<String, dynamic> credential) async {
    HiveUtils.setJWT(credential['token']);
    final data = credential['data'];
    final isProfileCompleted = _isProfileCompleted(data);

    if (!isProfileCompleted) {
      HiveUtils.setProfileNotCompleted();
    }

    HiveUtils.setUserData(data);
    emit(LoginSuccess(
      apiResponse: Map<String, dynamic>.from(data),
      isProfileCompleted: isProfileCompleted,
      credential: credential,
    ));
  }

  /// Checks if the profile is completed
  bool _isProfileCompleted(Map<String, dynamic> data) {
    return !(data['name'] == "" ||
        data['name'] == null ||
        data['email'] == "" ||
        data['email'] == null);
  }

  /// Validates Twilio credential format
  bool _isValidTwilioCredential(Map<String, dynamic> credential) {
    return credential.containsKey('token') && credential.containsKey('data');
  }
}
