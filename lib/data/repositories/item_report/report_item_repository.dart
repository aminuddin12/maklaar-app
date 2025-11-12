import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/data/model/report_item/reason_model.dart';
import 'package:com.maklaar.app/utils/api.dart';

class ReportItemRepository {
  Future<DataOutput<ReportReason>> fetchReportReasonsList() async {
    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getReportReasonsApi,
        queryParameters: {},
      );

      List<ReportReason> list = (response['data']['data'] as List).map((e) {
        return ReportReason(
          id: e["id"],
          reason: e['translated_reason'] ?? e['reason'],
        );
      }).toList();

      return DataOutput(total: response['total'], modelList: list);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> reportItem({
    required int reasonId,
    required int itemId,
    String? message,
  }) async {
    try {
      Map response = await Api.post(
        url: Api.addReportsApi,
        parameter: {
          Api.reportReasonId: (reasonId == -10) ? "" : reasonId,
          Api.itemId: itemId,
          if (message != null) Api.otherMessage: message,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
