import 'package:flutter/foundation.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    loadUserProfile();
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;
  UserProfile? _userProfile;

  bool get isLoggingOut => _isLoggingOut;
  bool get isLoadingProfile => _isLoadingProfile;
  UserProfile? get userProfile => _userProfile;
  String get userName => _userProfile?.nombre.trim().isNotEmpty == true
      ? _userProfile!.nombre.trim()
      : 'Usuario';

  Future<void> loadUserProfile() async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      final uid = await _authRepository.authStateChanges().first;
      if (uid != null) {
        _userProfile = await _userRepository.getUserById(uid);
      }
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    if (_isLoggingOut) return false;
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
