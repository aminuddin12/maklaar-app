import 'package:com.maklaar.app/data/model/home/home_screen_section_model.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/data/repositories/home/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchHomeScreenState {}

class FetchHomeScreenInitial extends FetchHomeScreenState {}

class FetchHomeScreenInProgress extends FetchHomeScreenState {}

class FetchHomeScreenSuccess extends FetchHomeScreenState {
  final List<HomeScreenSection> sections;

  FetchHomeScreenSuccess(this.sections);
}

class FetchHomeScreenFail extends FetchHomeScreenState {
  final dynamic error;

  FetchHomeScreenFail(this.error);
}

class FetchHomeScreenCubit extends Cubit<FetchHomeScreenState> {
  FetchHomeScreenCubit() : super(FetchHomeScreenInitial());

  final HomeRepository _homeRepository = HomeRepository();

  void fetch({required LeafLocation? location}) async {
    try {
      emit(FetchHomeScreenInProgress());
      List<HomeScreenSection> homeScreenDataList = await _homeRepository
          .fetchHome(location: location);

      emit(FetchHomeScreenSuccess(homeScreenDataList));
    } catch (e) {
      emit(FetchHomeScreenFail(e));
    }
  }
}
