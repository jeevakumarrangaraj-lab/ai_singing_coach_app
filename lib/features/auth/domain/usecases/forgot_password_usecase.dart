import '../errors/auth_failure.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<AuthFailure?> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
