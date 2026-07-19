import '../errors/auth_failure.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<AuthFailure?> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
