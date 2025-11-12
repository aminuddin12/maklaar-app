import 'package:com.maklaar.app/data/model/user/verification_request_model.dart';
import 'package:com.maklaar.app/data/repositories/seller/seller_verification_field_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchVerificationRequestState {}

class FetchVerificationRequestInitial extends FetchVerificationRequestState {}

class FetchVerificationRequestInProgress
    extends FetchVerificationRequestState {}

class FetchVerificationRequestSuccess extends FetchVerificationRequestState {
  final VerificationRequestModel data;

  FetchVerificationRequestSuccess(this.data);
}

class FetchVerificationRequestFail extends FetchVerificationRequestState {
  final dynamic error;

  FetchVerificationRequestFail(this.error);
}

class FetchVerificationRequestsCubit
    extends Cubit<FetchVerificationRequestState> {
  FetchVerificationRequestsCubit() : super(FetchVerificationRequestInitial());
  final SellerVerificationFieldRepository repository =
      SellerVerificationFieldRepository();

  void fetchVerificationRequests() async {
    try {
      emit(FetchVerificationRequestInProgress());
      VerificationRequestModel result =
          await repository.getVerificationRequest();
      emit(FetchVerificationRequestSuccess(result));
    } catch (e) {
      emit(FetchVerificationRequestFail(e.toString()));
    }
  }
}
