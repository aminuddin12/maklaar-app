import 'package:com.maklaar.app/data/model/blog_model.dart';
import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/utils/api.dart';

class BlogsRepository {
  Future<DataOutput<BlogModel>> fetchBlogs({required int page}) async {
    Map<String, dynamic> parameters = {
      Api.page: page,
      Api.sortBy: 'new-to-old',
    };

    Map<String, dynamic> result = await Api.get(
      url: Api.getBlogApi,
      queryParameters: parameters,
    );

    List<BlogModel> modelList = (result['data']['data'] as List)
        .map((element) => BlogModel.fromJson(element))
        .toList();

    return DataOutput<BlogModel>(
      total: result['data']['total'] ?? 0,
      modelList: modelList,
    );
  }
}
