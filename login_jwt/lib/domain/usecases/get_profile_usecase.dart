import '../repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute() async {
    return await repository.getProfile();
  }
}
