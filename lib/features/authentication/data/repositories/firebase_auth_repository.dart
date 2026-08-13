import 'package:firebase_auth/firebase_auth.dart';
import 'package:oculist/features/authentication/data/services/firebase_auth_service.dart';
import 'package:oculist/features/authentication/domain/exceptions/auth_exception.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required FirebaseAuthService authService})
    : _authService = authService;

  final FirebaseAuthService _authService;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'No fue posible obtener la información del usuario.',
        );
      }

      return user.uid;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error.code));
    }
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  String? get currentUserId {
    return _authService.currentUser?.uid;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Correo o contraseña incorrectos.';

      case 'user-disabled':
        return 'Esta cuenta se encuentra deshabilitada.';

      case 'too-many-requests':
        return 'Se realizaron demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No se pudo conectar con el servicio. Revisa tu conexión a Internet.';

      default:
        return 'No fue posible iniciar sesión. Intenta nuevamente.';
    }
  }

  @override
  Stream<String?> authStateChanges() {
    return _authService.authStateChanges().map((user) => user?.uid);
  }
}
