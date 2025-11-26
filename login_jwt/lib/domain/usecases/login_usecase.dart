import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String username, String password) async {
    // Validate inputs
    final usernameError = Validators.validateUsername(username);
    if (usernameError != null) {
      throw ValidationFailure(usernameError);
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationFailure(passwordError);
    }

    // Execute login
    return await repository.login(username, password);
  }
}
