import '../errors/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  SignupUseCase({required this._repository});

  final AuthRepository _repository;

  Future<AuthFailure?> call({required String email, required String password}) {
    return _repository.signUp(email: email, password: password);
  }
}
