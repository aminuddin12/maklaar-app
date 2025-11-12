import 'dart:convert';
import 'dart:io';

import 'package:com.maklaar.app/settings.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:com.maklaar.app/utils/hive_utils.dart';
import 'package:com.maklaar.app/utils/payment/gateaways/stripe_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGateways {
  static String generateReference(String email) {
    late String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else if (Platform.isAndroid) {
      platform = 'A';
    }
    String reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  static Future<void> stripe(BuildContext context,
      {required double price,
      required int packageId,
      required dynamic paymentIntent}) async {
    String paymentIntentId = paymentIntent["id"].toString();
    String clientSecret =
        paymentIntent['payment_gateway_response']["client_secret"].toString();

    await StripeService.payWithPaymentSheet(
      context: context,
      merchantDisplayName: Constant.appName,
      amount: paymentIntent["amount"].toString(),
      currency: AppSettings.stripeCurrency,
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
  }

  static Future<void> phonepeCheckSum(
      {required BuildContext context, required dynamic getData}) async {
    try {
      await PhonePePaymentSdk.init(
        getData["environment"],
        getData["merchantId"],
        getData["flowId"],
        getData["enableLogging"],
      ).then((val) {
        Map<String, dynamic> payload = {
          "orderId": getData["request"]["orderId"],
          "merchantId": getData["request"]["merchantId"],
          "token": getData["request"]["token"],
          "paymentMode": {"type": "PAY_PAGE"}
        };

        String request = jsonEncode(payload);
        print("Payment Request: $request");

/*        dynamic body = getData["request"];
        dynamic bodyData = {
          body["orderId"],
          body["merchantId"],
          body["token"],
          body["paymentMode"],
        };

        String data = jsonEncode(bodyData);*/
        startPaymentPhonePe(
          context: context,
          request: request,
          appSchema: getData["appSchema"],
        );
      }).catchError((error) {
        print("phonepe catch error***${error.toString()}");
        HelperUtils.showSnackBarMessage(
          context,
          error.toString(),
          type: MessageType.error,
        );
        return <dynamic>{};
      });
    } catch (error) {
      print("phonepe error***${error.toString()}");
      HelperUtils.showSnackBarMessage(
        context,
        error.toString(),
        type: MessageType.error,
      );
    }
  }

  static void startPaymentPhonePe({
    required BuildContext context,
    required String request,
    required String appSchema,
  }) async {
    try {
      PhonePePaymentSdk.startTransaction(request, appSchema).then((response) {
        print('phonepe response***$response');
        if (response != null) {
          String status = response['status'].toString();
          print("phonepe status***$status");
          if (status == 'SUCCESS') {
            print("status success");
            HelperUtils.showSnackBarMessage(
              context,
              "paymentSuccessfullyCompleted".translate(context),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            print("phonepe else failed***");
            HelperUtils.showSnackBarMessage(
              context,
              "purchaseFailed".translate(context),
              type: MessageType.error,
            );
          }
        } else {
          print("phonepe else failed1***");
          HelperUtils.showSnackBarMessage(
            context,
            "purchaseFailed".translate(context),
            type: MessageType.error,
          );
        }
      }).catchError((error) {
        print("phonepe error22***${error.toString()}");
        HelperUtils.showSnackBarMessage(
          context,
          error.toString(),
          type: MessageType.error,
        );
        return <dynamic>{};
      });
    } catch (error) {
      print("phonepe error11***${error.toString()}");
      HelperUtils.showSnackBarMessage(
        context,
        error.toString(),
        type: MessageType.error,
      );
    }
  }

  static void razorpay(
      {required BuildContext context,
      required price,
      required orderId,
      required packageId}) {
    final Razorpay razorpay = Razorpay();

    var options = {
      'key': AppSettings.razorpayKey,
      'amount': price! * 100,
      'name': HiveUtils.getUserDetails().name ?? "",
      'description': '',
      'order_id': orderId,
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile ?? "",
        'email': HiveUtils.getUserDetails().email ?? ""
      },
      "notes": {"package_id": packageId, "user_id": HiveUtils.getUserId()},
    };

    if (AppSettings.razorpayKey != "") {
      razorpay.open(options);
      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (
          PaymentSuccessResponse response,
        ) async {
          await _purchase(context);
        },
      );
      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
          HelperUtils.showSnackBarMessage(
              context, "purchaseFailed".translate(context));
        },
      );
      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (e) {},
      );
    } else {
      HelperUtils.showSnackBarMessage(context, "setAPIkey".translate(context));
    }
  }

  static Future<void> _purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.showSnackBarMessage(context, "success".translate(context),
              type: MessageType.success, messageDuration: 5);

          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context, "purchaseFailed".translate(context),
          type: MessageType.error);
    }
  }
}
