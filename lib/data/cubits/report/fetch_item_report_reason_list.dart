import 'package:com.maklaar.app/data/model/report_item/reason_model.dart';
import 'package:com.maklaar.app/data/repositories/item_report/report_item_repository.dart';
import 'package:com.maklaar.app/utils/constant.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for item report reasons list
abstract class FetchItemReportReasonsListState {}

class FetchItemReportReasonsInitial extends FetchItemReportReasonsListState {}

class FetchItemReportReasonsInProgress extends FetchItemReportReasonsListState {}

class FetchItemReportReasonsSuccess extends FetchItemReportReasonsListState {
  final int total;
  final List<ReportReason> reasons;

  FetchItemReportReasonsSuccess({
    required this.total,
    required this.reasons,
  });

  Map<String, dynamic> toMap() => {
        'total': total,
        'reasons': reasons.map((e) => e.toMap()).toList(),
      };

  factory FetchItemReportReasonsSuccess.fromMap(Map<String, dynamic> map) =>
      FetchItemReportReasonsSuccess(
        total: map['total'] as int,
        reasons: (map['reasons'] as List)
            .map((e) => ReportReason.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

class FetchItemReportReasonsFailure extends FetchItemReportReasonsListState {
  final String error;

  FetchItemReportReasonsFailure(this.error);
}

/// Cubit responsible for managing item report reasons list
class FetchItemReportReasonsListCubit
    extends Cubit<FetchItemReportReasonsListState> {
  FetchItemReportReasonsListCubit() : super(FetchItemReportReasonsInitial());
  
  final ReportItemRepository _repository = ReportItemRepository();

  /// Fetches the list of report reasons
  /// 
  /// [forceRefresh] - If true, forces a refresh of the data even if it's already loaded
  Future<void> fetch({bool? forceRefresh}) async {
    try {
      if (!_shouldFetch(forceRefresh)) return;

      emit(FetchItemReportReasonsInProgress());

      final result = await _repository.fetchReportReasonsList();
      final reasons = _addOtherReason(result.modelList);

      emit(FetchItemReportReasonsSuccess(
        reasons: reasons,
        total: result.total,
      ));
    } catch (e) {
      emit(FetchItemReportReasonsFailure(e.toString()));
    }
  }

  /// Determines if the fetch operation should proceed
  bool _shouldFetch(bool? forceRefresh) {
    if (forceRefresh == true) return true;
    if (state is FetchItemReportReasonsSuccess) {
      return false;
    }
    return true;
  }

  /// Adds the "other" reason to the list of reasons
  List<ReportReason> _addOtherReason(List<ReportReason> reasons) {
    final otherReason = ReportReason(
      id: -10,
      reason: "other".translate(Constant.navigatorKey.currentContext!),
    );
    return [...reasons, otherReason];
  }

  /// Gets the current list of reasons if available
  List<ReportReason>? getList() {
    if (state is FetchItemReportReasonsSuccess) {
      return (state as FetchItemReportReasonsSuccess).reasons;
    }
    return null;
  }

  /// Converts JSON to state
  FetchItemReportReasonsListState? fromJson(Map<String, dynamic> json) {
    try {
      return FetchItemReportReasonsSuccess.fromMap(json);
    } catch (e) {
      // Log error if needed
      return null;
    }
  }

  /// Converts state to JSON
  Map<String, dynamic>? toJson(FetchItemReportReasonsListState state) {
    try {
      if (state is FetchItemReportReasonsSuccess) {
        return state.toMap();
      }
    } catch (e) {
      // Log error if needed
    }
    return null;
  }
}
