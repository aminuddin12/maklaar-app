import 'package:com.maklaar.app/utils/api.dart';

class InAppPurchaseRepository {
  Future<Map> inAppPurchases(
      {required String purchaseToken,
      required String method,
      required int packageId}) async {
    Map<String, dynamic> parameters = {
      Api.purchaseToken: purchaseToken,
      Api.paymentMethod: method,
      Api.packageId: packageId
    };

    Map<String, dynamic> response = await Api.post(
      parameter: parameters,
      url: Api.inAppPurchaseApi,
    );

    return response;
  }
}
