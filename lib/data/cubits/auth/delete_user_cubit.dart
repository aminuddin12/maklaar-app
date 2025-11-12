import 'package:com.maklaar.app/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for the delete user operation
abstract class DeleteUserState {
  const DeleteUserState();
}

/// Initial state when no delete operation has been performed
class DeleteUserInitial extends DeleteUserState {
  const DeleteUserInitial();
}

/// State indicating that the delete operation is in progress
class DeleteUserFetchInProgress extends DeleteUserState {
  const DeleteUserFetchInProgress();
}

/// State indicating successful deletion of user
class DeleteUserFetchSuccess extends DeleteUserState {
  final dynamic deleteUser;

  const DeleteUserFetchSuccess({required this.deleteUser});
}

/// State indicating failure in user deletion
class DeleteUserFetchFailure extends DeleteUserState {
  final String errorMessage;

  const DeleteUserFetchFailure(this.errorMessage);
}

/// Cubit responsible for handling user deletion operations
class DeleteUserCubit extends Cubit<DeleteUserState> {
  final AuthRepository _deleteUserRepository;

  /// Creates a new instance of [DeleteUserCubit]
  DeleteUserCubit({AuthRepository? deleteUserRepository})
      : _deleteUserRepository = deleteUserRepository ?? AuthRepository(),
        super(const DeleteUserInitial());

  /// Deletes the user account
  /// 
  /// Returns the result of the deletion operation
  /// Throws an error if the deletion fails
  Future<dynamic> deleteUser() async {
    try {
      emit(const DeleteUserFetchInProgress());
      
      final result = await _deleteUserRepository.deleteUser();
      
      emit(DeleteUserFetchSuccess(deleteUser: result));
      return result;
    } catch (e) {
      final errorMessage = e.toString();
      emit(DeleteUserFetchFailure(errorMessage));
      throw errorMessage;
    }
  }
}
