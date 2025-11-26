import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'presentation/controllers/auth_controller.dart';

class InjectionContainer {
  static late AuthController authController;

  static void init() {
    // External
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final httpClient = http.Client();

    // Data sources
    final localStorageDataSource = LocalStorageDataSourceImpl(
      secureStorage: secureStorage,
    );

    // Repository
    final AuthRepository authRepository = AuthRepositoryImpl(
      localStorageDataSource: localStorageDataSource,
      httpClient: httpClient,
    );

    // Use cases
    final loginUseCase = LoginUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final getProfileUseCase = GetProfileUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);

    // Controller
    authController = AuthController(
      loginUseCase: loginUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      getProfileUseCase: getProfileUseCase,
      logoutUseCase: logoutUseCase,
    );
  }
}
