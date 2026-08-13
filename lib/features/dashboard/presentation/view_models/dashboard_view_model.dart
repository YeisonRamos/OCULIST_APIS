import 'package:flutter/foundation.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoggingOut = false;

  bool get isLoggingOut => _isLoggingOut;

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

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
