import 'package:com.maklaar.app/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for API keys
abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysFail extends GetApiKeysState {
  final String error;
  GetApiKeysFail(this.error);
}

/// Success state containing all payment gateway settings
class GetApiKeysSuccess extends GetApiKeysState {
  // Payment gateway API keys
  final String? razorPayApiKey;
  final String? payStackApiKey;
  final String? stripePublishableKey;
  final String? phonePeKey;
  final String? flutterWaveKey;

  // Currency codes
  final String? razorPayCurrency;
  final String? payStackCurrency;
  final String? stripeCurrency;
  final String? phonePeCurrency;
  final String? flutterWaveCurrency;

  // Bank transfer details
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankIfscSwiftCode;

  // Status flags
  final int razorPayStatus;
  final int payStackStatus;
  final int stripeStatus;
  final int phonePeStatus;
  final int flutterWaveStatus;
  final int bankTransferStatus;

  GetApiKeysSuccess({
    this.razorPayApiKey,
    this.razorPayCurrency,
    this.payStackApiKey,
    this.payStackCurrency,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.phonePeKey,
    this.phonePeCurrency,
    this.flutterWaveKey,
    this.flutterWaveCurrency,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankName,
    this.bankIfscSwiftCode,
    this.razorPayStatus = 0,
    this.payStackStatus = 0,
    this.stripeStatus = 0,
    this.phonePeStatus = 0,
    this.flutterWaveStatus = 0,
    this.bankTransferStatus = 0,
  });
}

/// Cubit responsible for managing payment API keys and settings
class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  /// Fetches payment API keys and settings from the server
  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());
      
      final result = await Api.get(url: Api.getPaymentSettingsApi);
      final data = result['data'] ?? {};

      emit(GetApiKeysSuccess(
        // Razorpay settings
        razorPayApiKey: _getData(data, Api.razorpay, Api.apiKey),
        razorPayCurrency: _getData(data, Api.razorpay, Api.currencyCode),
        razorPayStatus: _getIntData(data, Api.razorpay, Api.status),
        
        // Paystack settings
        payStackApiKey: _getData(data, Api.payStack, Api.apiKey),
        payStackCurrency: _getData(data, Api.payStack, Api.currencyCode),
        payStackStatus: _getIntData(data, Api.payStack, Api.status),
        
        // Stripe settings
        stripeCurrency: _getData(data, Api.stripe, Api.currencyCode),
        stripePublishableKey: _getData(data, Api.stripe, Api.apiKey),
        stripeStatus: _getIntData(data, Api.stripe, Api.status),
        
        // PhonePe settings
        phonePeKey: _getData(data, Api.phonePe, Api.apiKey),
        phonePeCurrency: _getData(data, Api.phonePe, Api.currencyCode),
        phonePeStatus: _getIntData(data, Api.phonePe, Api.status),
        
        // Flutterwave settings
        flutterWaveKey: _getData(data, Api.flutterwave, Api.apiKey),
        flutterWaveCurrency: _getData(data, Api.flutterwave, Api.currencyCode),
        flutterWaveStatus: _getIntData(data, Api.flutterwave, Api.status),
        
        // Bank transfer settings
        bankAccountHolder: _getData(data, Api.bankTransfer, Api.accountHolderName),
        bankAccountNumber: _getData(data, Api.bankTransfer, Api.accountNumber),
        bankName: _getData(data, Api.bankTransfer, Api.bankName),
        bankIfscSwiftCode: _getData(data, Api.bankTransfer, Api.ifscSwiftCode),
        bankTransferStatus: _getIntData(data, Api.bankTransfer, Api.status),
      ));
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  /// Gets string data from nested map with default value
  /// 
  /// [data] - The data map to search in
  /// [type] - The payment gateway type
  /// [key] - The key to look up
  /// [defaultValue] - Default value if key is not found
  String _getData(
    Map<String, dynamic> data,
    String type,
    String key, {
    String defaultValue = '',
  }) =>
      data[type]?[key]?.toString() ?? defaultValue;

  /// Gets integer data from nested map with default value
  /// 
  /// [data] - The data map to search in
  /// [type] - The payment gateway type
  /// [key] - The key to look up
  /// [defaultValue] - Default value if key is not found
  int _getIntData(
    Map<String, dynamic> data,
    String type,
    String key, {
    int defaultValue = 0,
  }) =>
      int.tryParse(
        _getData(data, type, key, defaultValue: defaultValue.toString()),
      ) ?? defaultValue;
}
