import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  String? get currentUserId => null;

  @override
  Stream<String?> authStateChanges() {
    return Stream.value(null);
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    return 'test-user-id';
  }

  @override
  Future<void> signOut() async {}
}

class FakeUserRepository implements UserRepository {
  @override
  Future<UserProfile> getUserById(String uid) async {
    return UserProfile(
      uid: uid,
      nombre: 'Usuario de prueba',
      correo: 'prueba@oculist.com',
      rol: UserRole.optico,
      activo: true,
    );
  }
}

class FakeClientRepository implements ClientRepository {
  @override
  Future<Client> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    return Client(
      id: 'test-client-id',
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      documentoIdentidad: documentoIdentidad,
      fechaRegistro: DateTime.now(),
      activo: true,
    );
  }

  @override
  Stream<List<Client>> watchActiveClients() {
    return Stream.value([]);
  }
}

void main() {
  testWidgets('Muestra correctamente la pantalla de inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      OculistApp(
        authRepository: FakeAuthRepository(),
        userRepository: FakeUserRepository(),
        clientRepository: FakeClientRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a OCULIST'), findsOneWidget);

    expect(find.byKey(const Key('email_field')), findsOneWidget);

    expect(find.byKey(const Key('password_field')), findsOneWidget);

    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
