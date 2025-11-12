import 'dart:developer';
import 'dart:io';

import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/error_filter.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/login/apple_login/apple_login.dart';
import 'package:com.maklaar.app/utils/login/email_login/email_login.dart';
import 'package:com.maklaar.app/utils/login/google_login/google_login.dart';
import 'package:com.maklaar.app/utils/login/lib/login_status.dart';
import 'package:com.maklaar.app/utils/login/lib/login_system.dart';
import 'package:com.maklaar.app/utils/login/lib/payloads.dart';
import 'package:com.maklaar.app/utils/login/phone_login/phone_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enum representing different authentication types
enum AuthenticationType {
  email,
  google,
  apple,
  phone,
}

/// Base class for all authentication states
abstract class AuthenticationState {
  const AuthenticationState();
}

/// Initial authentication state
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// Authentication in process state with type information
class AuthenticationInProcess extends AuthenticationState {
  final AuthenticationType type;

  const AuthenticationInProcess(this.type);
}

/// Successful authentication state with credentials and payload
class AuthenticationSuccess extends AuthenticationState {
  final AuthenticationType type;
  final dynamic credential;
  final LoginPayload payload;
  final String? authId;

  const AuthenticationSuccess(
      this.type, this.credential, this.payload, this.authId);
}

/// Failed authentication state with error information
class AuthenticationFail extends AuthenticationState {
  final String errorKey;

  const AuthenticationFail(this.errorKey);
}

/// Cubit for handling authentication logic
class AuthenticationCubit extends Cubit<AuthenticationState> {
  /// Creates a new instance of [AuthenticationCubit]
  AuthenticationCubit() : super(const AuthenticationInitial());

  AuthenticationType? type;
  LoginPayload? payload;

  /// Multi-authentication system instance
  final MMultiAuthentication mMultiAuthentication = MMultiAuthentication({
    "google": GoogleLogin(),
    "email": EmailLogin(),
    if (Platform.isIOS) "apple": AppleLogin(),
    "phone": PhoneLogin(),
  });

  /// Initializes the authentication system
  void init() {
    mMultiAuthentication.init();
  }

  /// Sets authentication data
  void setData({
    required LoginPayload payload,
    required AuthenticationType type,
  }) {
    this.type = type;
    this.payload = payload;
  }

  /// Performs authentication based on the set type and payload
  Future<void> authenticate() async {
    if (type == null || payload == null) {
      return;
    }

    try {
      emit(AuthenticationInProcess(type!));
      await _setupAuthentication();

      if (_isTwilioVerificationRequired()) {
        await _handleTwilioAuthentication();
      } else {
        await _handleStandardAuthentication();
      }
    } on FirebaseAuthException catch (e) {
      print("firebase error***${e.code.toString()}***${e.message.toString()}");
      _handleFirebaseAuthError(e);
    } catch (e, stack) {
      print("error auth***${e.toString()}");
      _handleGeneralError(e, stack);
    }
  }

  /// Sets up the authentication system with current type and payload
  Future<void> _setupAuthentication() async {
    mMultiAuthentication.setActive(type!.name);
    mMultiAuthentication.payload = MultiLoginPayload({
      type!.name: payload!,
    });
  }

  /// Checks if Twilio verification is required
  bool _isTwilioVerificationRequired() {
    return Constant.otpServiceProvider == 'twilio' &&
        payload is PhoneLoginPayload;
  }

  /// Handles Twilio authentication
  Future<void> _handleTwilioAuthentication() async {
    final twilio = await verifyTwilioOtp();
    if (twilio['error'] == true) {
      emit(AuthenticationFail(twilio['message']));
      return;
    }

    final token = twilio['token']?.toString() ?? '';
    final credentials = twilio['data'];
    emit(AuthenticationSuccess(type!, credentials, payload!, token));
  }

  /// Handles standard authentication flow
  Future<void> _handleStandardAuthentication() async {
    final credential = await mMultiAuthentication.login();
    if (credential == null) return;

    if (_isEmailLoginWithUnverifiedEmail(credential)) {
      _handleUnverifiedEmail();
    } else {
      emit(AuthenticationSuccess(type!, credential, payload!, null));
    }
  }

  /// Checks if the current login is an unverified email login
  bool _isEmailLoginWithUnverifiedEmail(UserCredential credential) {
    return payload is EmailLoginPayload &&
        (payload as EmailLoginPayload).type == EmailLoginType.login &&
        credential.user != null &&
        !credential.user!.emailVerified;
  }

  /// Handles unverified email case
  void _handleUnverifiedEmail() {
    emit(AuthenticationFail(
      "pleaseVerifyYourEmail".translate(Constant.navigatorKey.currentContext!),
    ));
  }

  /// Handles Firebase authentication errors
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    log(e.toString());
    emit(AuthenticationFail(
        ErrorFilter.getErrorKeyFromFirebaseAuthException(e)));
  }

  /// Handles general errors
  void _handleGeneralError(dynamic e, StackTrace stack) {
    print(e.toString());
    print('$stack');
    emit(AuthenticationFail(e.toString()));
  }

  /// Verifies Twilio OTP
  Future<Map<String, dynamic>> verifyTwilioOtp() async {
    final phonePayload = payload as PhoneLoginPayload;
    final parameters = {
      'number': "+${phonePayload.countryCode}${phonePayload.phoneNumber}",
      'otp': phonePayload.getOTP(),
    };

    return await Api.get(
      url: Api.verifyTwilioOtp,
      queryParameters: parameters,
    );
  }

  /// Sets up authentication listener
  void listen(Function(MLoginState state) fn) {
    mMultiAuthentication.listen(fn);
  }

  /// Requests verification for the current authentication
  void verify() {
    mMultiAuthentication.setActive(type!.name);
    mMultiAuthentication.payload = MultiLoginPayload({
      type!.name: payload!,
    });
    mMultiAuthentication.requestVerification();
  }

  /// Signs out the current user
  Future<void> signOut() async {
    if (state is AuthenticationSuccess) {
      final authType = (state as AuthenticationSuccess).type;

      await FirebaseAuth.instance.signOut();

      if (authType == AuthenticationType.google) {
        final googleLogin =
            mMultiAuthentication.systems['google'] as GoogleLogin;
        googleLogin.signOut();
      }

      emit(const AuthenticationInitial());
    }
  }
}
