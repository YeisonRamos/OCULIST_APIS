import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/clients/presentation/view_models/client_detail_view_model.dart';
import 'package:oculist/features/clients/presentation/view_models/client_list_view_model.dart';
import 'package:oculist/features/clients/presentation/view_models/register_client_view_model.dart';

class FakeClientRepository implements ClientRepository {
  FakeClientRepository()
    : _clients = [
        Client(
          id: 'cliente-1',
          nombres: 'María',
          apellidos: 'Pérez',
          telefono: '70000001',
          documentoIdentidad: '1111111',
          fechaRegistro: DateTime(2026, 8, 1),
          activo: true,
        ),
        Client(
          id: 'cliente-2',
          nombres: 'Carlos',
          apellidos: 'Mamani',
          telefono: '70000002',
          documentoIdentidad: '2222222',
          fechaRegistro: DateTime(2026, 8, 2),
          activo: true,
        ),
      ];

  final List<Client> _clients;

  String? deactivatedClientId;

  @override
  Future<Client> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    return Client(
      id: 'nuevo-cliente',
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
    return Stream.value(_clients.where((client) => client.activo).toList());
  }

  @override
  Future<Client> getClientById(String clientId) async {
    return _clients.firstWhere((client) => client.id == clientId);
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
      fechaRegistro: DateTime(2026, 8, 1),
      activo: true,
    );
  }

  @override
  Future<String> saveFacePhoto({
    required String clientId,
    required String filePath,
  }) async {
    return 'https://example.com/client-face.jpg';
  }

  @override
  Future<void> deactivateClient(String clientId) async {
    deactivatedClientId = clientId;
  }
}

void main() {
  group('RegisterClientViewModel', () {
    test('valida nombres vacíos', () {
      final viewModel = RegisterClientViewModel(
        clientRepository: FakeClientRepository(),
      );

      final result = viewModel.validateNames('');

      expect(result, 'Ingresa los nombres del cliente');
    });

    test('rechaza teléfono inválido', () {
      final viewModel = RegisterClientViewModel(
        clientRepository: FakeClientRepository(),
      );

      final result = viewModel.validatePhone('abc');

      expect(result, 'Ingresa un número de teléfono válido');
    });

    test('registra correctamente un cliente', () async {
      final viewModel = RegisterClientViewModel(
        clientRepository: FakeClientRepository(),
      );

      final success = await viewModel.registerClient(
        nombres: 'Ana',
        apellidos: 'Flores',
        telefono: '70000003',
        documentoIdentidad: '3333333',
      );

      expect(success, isTrue);
      expect(viewModel.createdClient, isNotNull);
      expect(viewModel.createdClient?.nombreCompleto, 'Ana Flores');
    });
  });

  group('ClientListViewModel', () {
    test('carga clientes activos', () async {
      final viewModel = ClientListViewModel(
        clientRepository: FakeClientRepository(),
      );

      viewModel.loadClients();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.filteredClients.length, 2);

      viewModel.dispose();
    });

    test('busca cliente por nombre', () async {
      final viewModel = ClientListViewModel(
        clientRepository: FakeClientRepository(),
      );

      viewModel.loadClients();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      viewModel.search('maria');

      expect(viewModel.filteredClients.length, 1);

      expect(viewModel.filteredClients.first.nombres, 'María');

      viewModel.dispose();
    });

    test('busca cliente por teléfono', () async {
      final viewModel = ClientListViewModel(
        clientRepository: FakeClientRepository(),
      );

      viewModel.loadClients();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      viewModel.search('70000002');

      expect(viewModel.filteredClients.length, 1);

      expect(viewModel.filteredClients.first.nombres, 'Carlos');

      viewModel.dispose();
    });
  });

  group('ClientDetailViewModel', () {
    test('desactiva correctamente un cliente', () async {
      final repository = FakeClientRepository();

      final viewModel = ClientDetailViewModel(
        clientRepository: repository,
        clientId: 'cliente-1',
      );

      final success = await viewModel.deactivateClient();

      expect(success, isTrue);

      expect(repository.deactivatedClientId, 'cliente-1');
    });
  });
}
