import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

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

  @override
  Future<Client> getClientById(String clientId) async {
    return Client(
      id: clientId,
      nombres: 'Usuario',
      apellidos: 'de prueba',
      telefono: '70000000',
      documentoIdentidad: '1234567',
      fechaRegistro: DateTime.now(),
      activo: true,
    );
  }

  @override
  Future<Client> updateClient({
    required String clientId,
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    return Client(
      id: clientId,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      documentoIdentidad: documentoIdentidad,
      fechaRegistro: DateTime.now(),
      activo: true,
    );
  }

  @override
  Future<String> saveFacePhoto({
    required String clientId,
    required String filePath,
    required FaceShape faceShape,
  }) async {
    return 'https://example.com/client-face.jpg';
  }

  @override
  Future<void> deactivateClient(String clientId) async {}
}

class FakeFrameRepository implements FrameRepository {
  @override
  Future<Frame> createFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    String? imagenUrl,
  }) async {
    return Frame(
      id: 'frame-test-id',
      codigo: codigo,
      marca: marca,
      modelo: modelo,
      color: color,
      forma: forma,
      material: material,
      talla: talla,
      imagenUrl: imagenUrl,
      disponible: true,
      activo: true,
      fechaRegistro: DateTime.now(),
    );
  }

  @override
  Stream<List<Frame>> watchActiveFrames() {
    return Stream.value([]);
  }

  @override
  Future<Frame> getFrameById(String frameId) async {
    return Frame(
      id: frameId,
      codigo: 'M001',
      marca: 'Marca de prueba',
      modelo: 'Modelo de prueba',
      color: 'Negro',
      forma: 'Rectangular',
      material: 'Acetato',
      talla: 'Mediana',
      disponible: true,
      activo: true,
      fechaRegistro: DateTime.now(),
    );
  }

  @override
  Future<Frame> updateFrame({
    required String frameId,
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
  }) async {
    return Frame(
      id: frameId,
      codigo: codigo,
      marca: marca,
      modelo: modelo,
      color: color,
      forma: forma,
      material: material,
      talla: talla,
      disponible: true,
      activo: true,
      fechaRegistro: DateTime.now(),
    );
  }

  @override
  Future<void> setAvailability({
    required String frameId,
    required bool disponible,
  }) async {}

  @override
  Future<void> deactivateFrame(String frameId) async {}

  @override
  Future<Frame> updateFrameImage({
    required String frameId,
    required String filePath,
  }) async {
    return Frame(
      id: frameId,
      codigo: 'M001',
      marca: 'Marca de prueba',
      modelo: 'Modelo de prueba',
      color: 'Negro',
      forma: 'Rectangular',
      material: 'Acetato',
      talla: 'Mediana',
      imagenUrl: 'https://example.com/montura.jpg',
      disponible: true,
      activo: true,
      fechaRegistro: DateTime.now(),
    );
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
        frameRepository: FakeFrameRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Oculist'), findsOneWidget);

    expect(find.byKey(const Key('email_field')), findsOneWidget);

    expect(find.byKey(const Key('password_field')), findsOneWidget);

    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
