import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetProfileUseCase getProfileUseCase;
  final LogoutUseCase logoutUseCase;

  AuthController({
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
    required this.getProfileUseCase,
    required this.logoutUseCase,
  });

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;
  bool _isLoadingProfile = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoadingProfile => _isLoadingProfile;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await loginUseCase.execute(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthenticationFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _currentUser = await getCurrentUserUseCase.execute();
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profileData = await getProfileUseCase.execute();
      _isLoadingProfile = false;
      notifyListeners();
    } on AuthenticationFailure catch (e) {
      _errorMessage = e.message;
      _isLoadingProfile = false;
      _currentUser = null;
      notifyListeners();
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      _isLoadingProfile = false;
      notifyListeners();
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile';
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      _currentUser = null;
      _profileData = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
