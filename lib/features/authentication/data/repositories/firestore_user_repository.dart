import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oculist/features/authentication/data/services/firestore_user_service.dart';
import 'package:oculist/features/authentication/domain/exceptions/user_profile_exception.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({required FirestoreUserService userService})
    : _userService = userService;

  final FirestoreUserService _userService;

  @override
  Future<UserProfile> getUserById(String uid) async {
    try {
      final data = await _userService.getUserById(uid);

      if (data == null) {
        throw const UserProfileException(
          'No se encontró el perfil del usuario.',
        );
      }

      final nombre = data['nombre'];
      final correo = data['correo'];
      final rol = data['rol'];
      final activo = data['activo'];

      if (nombre is! String ||
          correo is! String ||
          rol is! String ||
          activo is! bool) {
        throw const UserProfileException(
          'El perfil del usuario contiene datos inválidos.',
        );
      }

      return UserProfile(
        uid: uid,
        nombre: nombre,
        correo: correo,
        rol: _parseRole(rol),
        activo: activo,
      );
    } on UserProfileException {
      rethrow;
    } on FirebaseException {
      throw const UserProfileException(
        'No fue posible obtener la información del usuario.',
      );
    }
  }

  UserRole _parseRole(String role) {
    switch (role) {
      case 'optico':
        return UserRole.optico;

      case 'administrador':
        return UserRole.administrador;

      default:
        throw const UserProfileException('El usuario tiene un rol no válido.');
    }
  }
}
