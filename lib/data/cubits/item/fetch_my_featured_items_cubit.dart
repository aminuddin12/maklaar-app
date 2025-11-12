import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/repositories/item/item_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyFeaturedItemsState {}

class FetchMyFeaturedItemsInitial extends FetchMyFeaturedItemsState {}

class FetchMyFeaturedItemsInProgress extends FetchMyFeaturedItemsState {}

class FetchMyFeaturedItemsSuccess extends FetchMyFeaturedItemsState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<ItemModel> itemModel;
  final int page;
  final int total;

  FetchMyFeaturedItemsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.itemModel,
    required this.page,
    required this.total,
  });

  FetchMyFeaturedItemsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<ItemModel>? itemModel,
    int? page,
    int? total,
  }) {
    return FetchMyFeaturedItemsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      itemModel: itemModel ?? this.itemModel,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchMyFeaturedItemsFailure extends FetchMyFeaturedItemsState {
  final dynamic errorMessage;

  FetchMyFeaturedItemsFailure(this.errorMessage);
}

class FetchMyFeaturedItemsCubit extends Cubit<FetchMyFeaturedItemsState> {
  FetchMyFeaturedItemsCubit() : super(FetchMyFeaturedItemsInitial());

  final ItemRepository _itemRepository = ItemRepository();

  Future<void> fetchMyFeaturedItems() async {
    try {
      emit(FetchMyFeaturedItemsInProgress());

      DataOutput<ItemModel> result =
          await _itemRepository.fetchMyFeaturedItems(page: 1);

      emit(
        FetchMyFeaturedItemsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          itemModel: result.modelList,
          page: 1,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchMyFeaturedItemsFailure(e));
    }
  }

  void delete(dynamic id) {
    if (state is FetchMyFeaturedItemsSuccess) {
      List<ItemModel> itemModel =
          (state as FetchMyFeaturedItemsSuccess).itemModel;
      itemModel.removeWhere((element) => element.id == id);

      emit((state as FetchMyFeaturedItemsSuccess)
          .copyWith(itemModel: itemModel));
    }
  }

  Future<void> fetchMyFeaturedItemsMore() async {
    try {
      if (state is FetchMyFeaturedItemsSuccess) {
        if ((state as FetchMyFeaturedItemsSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMyFeaturedItemsSuccess)
            .copyWith(isLoadingMore: true));
        DataOutput<ItemModel> result =
            await _itemRepository.fetchMyFeaturedItems(
          page: (state as FetchMyFeaturedItemsSuccess).page + 1,
        );

        FetchMyFeaturedItemsSuccess itemModelState =
            (state as FetchMyFeaturedItemsSuccess);
        itemModelState.itemModel.addAll(result.modelList);
        emit(FetchMyFeaturedItemsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            itemModel: itemModelState.itemModel,
            page: (state as FetchMyFeaturedItemsSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchMyFeaturedItemsSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchMyFeaturedItemsSuccess) {
      return (state as FetchMyFeaturedItemsSuccess).itemModel.length <
          (state as FetchMyFeaturedItemsSuccess).total;
    }
    return false;
  }

  void update(ItemModel model) {
    if (state is FetchMyFeaturedItemsSuccess) {
      List<ItemModel> items = (state as FetchMyFeaturedItemsSuccess).itemModel;

      var index = items.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        items[index] = model;
      }

      emit((state as FetchMyFeaturedItemsSuccess).copyWith(itemModel: items));
    }
  }
}
