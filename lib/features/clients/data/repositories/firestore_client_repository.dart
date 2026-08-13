import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oculist/features/clients/data/services/firestore_client_service.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class FirestoreClientRepository implements ClientRepository {
  FirestoreClientRepository({required FirestoreClientService clientService})
    : _clientService = clientService;

  final FirestoreClientService _clientService;

  @override
  Future<Client> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    final cleanNames = nombres.trim();
    final cleanLastNames = apellidos.trim();
    final cleanPhone = telefono.trim();

    final cleanDocument = documentoIdentidad?.trim();

    try {
      final id = await _clientService.createClient(
        nombres: cleanNames,
        apellidos: cleanLastNames,
        telefono: cleanPhone,
        documentoIdentidad: cleanDocument?.isEmpty == true
            ? null
            : cleanDocument,
      );

      return Client(
        id: id,
        nombres: cleanNames,
        apellidos: cleanLastNames,
        telefono: cleanPhone,
        documentoIdentidad: cleanDocument?.isEmpty == true
            ? null
            : cleanDocument,
        fechaRegistro: DateTime.now(),
        activo: true,
      );
    } on FirebaseException {
      throw const ClientException('No fue posible registrar al cliente.');
    } catch (_) {
      throw const ClientException(
        'Ocurrió un error inesperado al registrar al cliente.',
      );
    }
  }
}
