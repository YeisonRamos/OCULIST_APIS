import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oculist/features/user_management/domain/exceptions/user_management_exception.dart';
import 'package:oculist/features/user_management/domain/models/managed_user.dart';

class UserManagementService {
  UserManagementService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ManagedUser>> watchOpticians() {
    return _firestore
        .collection('usuarios')
        .where('rol', isEqualTo: 'optico')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs.map(_fromDocument).toList()
            ..sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
          return users;
        });
  }

  Future<void> createOptician({
    required String nombreCompleto,
    required String correo,
    required String password,
  }) async {
    FirebaseApp? secondaryApp;
    User? createdUser;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'crear_optico_${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const UserManagementException('No fue posible crear la cuenta.');
      }
      await _firestore.collection('usuarios').doc(createdUser.uid).set({
        'nombreCompleto': nombreCompleto.trim(),
        'correo': correo.trim().toLowerCase(),
        'rol': 'optico',
        'activo': true,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      await secondaryAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw UserManagementException(_authMessage(error.code));
    } on FirebaseException {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }
      throw const UserManagementException(
        'No fue posible guardar el perfil del óptico.',
      );
    } finally {
      await secondaryApp?.delete();
    }
  }

  Future<void> updateName(String uid, String nombreCompleto) {
    return _firestore.collection('usuarios').doc(uid).update({
      'nombreCompleto': nombreCompleto.trim(),
    });
  }

  Future<void> setActive(String uid, bool active) {
    return _firestore.collection('usuarios').doc(uid).update({
      'activo': active,
    });
  }

  ManagedUser _fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['fechaRegistro'];
    return ManagedUser(
      uid: document.id,
      nombreCompleto: (data['nombreCompleto'] as String? ?? '').trim(),
      correo: (data['correo'] as String? ?? '').trim(),
      activo: data['activo'] as bool? ?? false,
      fechaRegistro: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo ya pertenece a otra cuenta.';
      case 'invalid-email':
        return 'Ingrese un correo electrónico válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'No hay conexión con Firebase.';
      default:
        return 'No fue posible registrar la cuenta del óptico.';
    }
  }
}
