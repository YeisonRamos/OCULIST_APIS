import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

abstract interface class ClientRepository {
  Future<Client> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  });

  Stream<List<Client>> watchActiveClients();

  Future<Client> getClientById(String clientId);

  Future<Client> updateClient({
    required String clientId,
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  });

  Future<String> saveFacePhoto({
    required String clientId,
    required String filePath,
    required FaceShape faceShape,
  });

  Future<void> deactivateClient(String clientId);
}
