import 'package:oculist/features/clients/domain/models/client.dart';

abstract interface class ClientRepository {
  Future<Client> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  });

  Stream<List<Client>> watchActiveClients();
}
