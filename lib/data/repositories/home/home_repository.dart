import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/data/model/home/home_screen_section_model.dart';
import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:com.maklaar.app/data/model/location/leaf_location.dart';
import 'package:com.maklaar.app/utils/api.dart';

class HomeRepository {
  Future<List<HomeScreenSection>> fetchHome({
    required LeafLocation? location,
  }) async {
    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getFeaturedSectionApi,
        queryParameters: location?.toApiJson(),
      );
      List<HomeScreenSection> homeScreenDataList = (response['data'] as List)
          .map((element) {
            return HomeScreenSection.fromJson(element);
          })
          .toList();

      return homeScreenDataList;
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchHomeAllItems({
    required int page,
    required LeafLocation? location,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        Api.page: page,
        ...?location?.toApiJson(),
      };

      Map<String, dynamic> response = await Api.get(
        url: Api.getItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: items,
      );
    } catch (error) {
      rethrow;
    }
  }


  Future<DataOutput<ItemModel>> fetchSectionItems({
    required int page,
    required int sectionId,
    required LeafLocation? location,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        Api.page: page,
        Api.featuredSectionId: sectionId,
        ...?location?.toApiJson(),
      };

      Map<String, dynamic> response = await Api.get(
        url: Api.getItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: items,
      );
    } catch (error) {
      rethrow;
    }
  }
}
