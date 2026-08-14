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

  @override
  Stream<List<Client>> watchActiveClients() {
    return _clientService.watchActiveClients().map((snapshot) {
      final clients = snapshot.docs.map(_clientFromDocument).toList();

      clients.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

      return clients;
    });
  }

  @override
  Future<Client> getClientById(String clientId) async {
    try {
      final document = await _clientService.getClientById(clientId);

      if (!document.exists) {
        throw const ClientException('No se encontró el cliente.');
      }

      return _clientFromDocument(document);
    } on ClientException {
      rethrow;
    } on FirebaseException {
      throw const ClientException(
        'No fue posible obtener la información del cliente.',
      );
    } catch (_) {
      throw const ClientException(
        'Ocurrió un error inesperado al consultar el cliente.',
      );
    }
  }

  Client _clientFromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    if (data == null) {
      throw const ClientException(
        'Los datos del cliente no están disponibles.',
      );
    }

    final timestamp = data['fechaRegistro'];

    return Client(
      id: document.id,
      nombres: data['nombres'] as String? ?? '',
      apellidos: data['apellidos'] as String? ?? '',
      telefono: data['telefono'] as String? ?? '',
      documentoIdentidad: data['documentoIdentidad'] as String?,
      fechaRegistro: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      activo: data['activo'] as bool? ?? false,
    );
  }
}
