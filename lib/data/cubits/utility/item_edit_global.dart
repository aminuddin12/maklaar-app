import 'package:com.maklaar.app/data/model/item/item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemEditGlobal {
  final List<ItemModel> list;

  ItemEditGlobal(this.list);
}

class ItemEditCubit extends Cubit<ItemEditGlobal> {
  ItemEditCubit() : super(ItemEditGlobal([]));

  ItemModel get(ItemModel model) {
    return state.list.firstWhere((element) => element.id == model.id,
        orElse: () {
      return model;
    });
  }
}
