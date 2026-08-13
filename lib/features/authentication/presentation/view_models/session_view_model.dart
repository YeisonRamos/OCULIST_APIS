import 'package:flutter/foundation.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';

enum SessionDestination { login, optico, administrador }

class SessionViewModel extends ChangeNotifier {
  SessionViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<SessionDestination> restoreSession() async {
    try {
      final uid = await _authRepository.authStateChanges().first;

      if (uid == null) {
        return SessionDestination.login;
      }

      final profile = await _userRepository.getUserById(uid);

      if (!profile.activo) {
        await _authRepository.signOut();
        return SessionDestination.login;
      }

      switch (profile.rol) {
        case UserRole.optico:
          return SessionDestination.optico;

        case UserRole.administrador:
          return SessionDestination.administrador;
      }
    } catch (_) {
      return SessionDestination.login;
    }
  }
}
