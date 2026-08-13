import 'package:flutter/foundation.dart';
import 'package:oculist/features/authentication/domain/exceptions/auth_exception.dart';
import 'package:oculist/features/authentication/domain/exceptions/user_profile_exception.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) {
      return false;
    }

    _errorMessage = null;
    _userProfile = null;
    _setLoading(true);

    var authenticated = false;

    try {
      final uid = await _authRepository.signIn(
        email: email.trim(),
        password: password,
      );

      authenticated = true;

      final profile = await _userRepository.getUserById(uid);

      if (!profile.activo) {
        await _safeSignOut();

        _errorMessage =
            'Esta cuenta se encuentra inactiva. Contacta al administrador.';

        return false;
      }

      _userProfile = profile;

      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } on UserProfileException catch (error) {
      if (authenticated) {
        await _safeSignOut();
      }

      _errorMessage = error.message;
      return false;
    } catch (_) {
      if (authenticated) {
        await _safeSignOut();
      }

      _errorMessage = 'Ocurrió un error inesperado. Intenta nuevamente.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _safeSignOut() async {
    try {
      await _authRepository.signOut();
    } catch (_) {
      // Evita ocultar el error original si falla el cierre de sesión.
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}
