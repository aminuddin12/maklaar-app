import 'package:com.maklaar.app/data/model/custom_field/custom_field_model.dart';
import 'package:com.maklaar.app/data/repositories/item/custom_fields_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchCustomFieldState {}

class FetchCustomFieldInitial extends FetchCustomFieldState {}

class FetchCustomFieldInProgress extends FetchCustomFieldState {}

class FetchCustomFieldSuccess extends FetchCustomFieldState {
  final List<CustomFieldModel> fields;

  FetchCustomFieldSuccess(this.fields);
}

class FetchCustomFieldFail extends FetchCustomFieldState {
  final dynamic error;

  FetchCustomFieldFail(this.error);
}

class FetchCustomFieldsCubit extends Cubit<FetchCustomFieldState> {
  FetchCustomFieldsCubit() : super(FetchCustomFieldInitial());
  final CustomFieldRepository _customFieldRepository = CustomFieldRepository();

  void fetchCustomFields({required String categoryIds}) async {
    try {
      emit(FetchCustomFieldInProgress());
      List<CustomFieldModel> result =
          await _customFieldRepository.getCustomFields(categoryIds);
      emit(FetchCustomFieldSuccess(result));
    } catch (e) {
      emit(FetchCustomFieldFail(e.toString()));
    }
  }

  List<CustomFieldModel> getFields() {
    if (state is FetchCustomFieldSuccess) {
      return (state as FetchCustomFieldSuccess).fields;
    }
    return [];
  }

  bool? isEmpty() {
    if (state is FetchCustomFieldSuccess) {
      return (state as FetchCustomFieldSuccess).fields.isEmpty;
    }
    return null;
  }
}
