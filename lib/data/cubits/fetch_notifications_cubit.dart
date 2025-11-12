import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/data/model/notification_model.dart';
import 'package:com.maklaar.app/data/repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchNotificationsState {}

class FetchNotificationsInitial extends FetchNotificationsState {}

class FetchNotificationsInProgress extends FetchNotificationsState {}

class FetchNotificationsSuccess extends FetchNotificationsState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<NotificationData> notificationData;
  final int page;
  final int total;

  FetchNotificationsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.notificationData,
    required this.page,
    required this.total,
  });

  FetchNotificationsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<NotificationData>? notificationData,
    int? page,
    int? total,
  }) {
    return FetchNotificationsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      notificationData: notificationData ?? this.notificationData,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchNotificationsFailure extends FetchNotificationsState {
  final dynamic errorMessage;

  FetchNotificationsFailure(this.errorMessage);
}

class FetchNotificationsCubit extends Cubit<FetchNotificationsState> {
  FetchNotificationsCubit() : super(FetchNotificationsInitial());

  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  Future fetchNotifications() async {
    try {
      emit(FetchNotificationsInProgress());

      DataOutput<NotificationData> result =
          await _notificationsRepository.fetchNotifications(page: 1);
      emit(FetchNotificationsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          notificationData: result.modelList,
          page: 1,
          total: result.total));
    } catch (e) {
      emit(FetchNotificationsFailure(e));
    }
  }

  Future<void> fetchNotificationsMore() async {
    try {
      if (state is FetchNotificationsSuccess) {
        if ((state as FetchNotificationsSuccess).isLoadingMore) {
          return;
        }
        emit(
            (state as FetchNotificationsSuccess).copyWith(isLoadingMore: true));
        DataOutput<NotificationData> result =
            await _notificationsRepository.fetchNotifications(
          page: (state as FetchNotificationsSuccess).page + 1,
        );

        FetchNotificationsSuccess notificationState =
            (state as FetchNotificationsSuccess);
        notificationState.notificationData.addAll(result.modelList);
        emit(FetchNotificationsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            notificationData: notificationState.notificationData,
            page: (state as FetchNotificationsSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchNotificationsSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchNotificationsSuccess) {
      return (state as FetchNotificationsSuccess).notificationData.length <
          (state as FetchNotificationsSuccess).total;
    }
    return false;
  }
}
