import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class ClientListViewModel extends ChangeNotifier {
  ClientListViewModel({required ClientRepository clientRepository})
    : _clientRepository = clientRepository;

  final ClientRepository _clientRepository;

  StreamSubscription<List<Client>>? _subscription;

  List<Client> _clients = [];
  String _searchText = '';
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Client> get filteredClients {
    final query = _normalize(_searchText);

    if (query.isEmpty) {
      return List.unmodifiable(_clients);
    }

    return _clients.where((client) {
      final values = [
        client.nombres,
        client.apellidos,
        client.nombreCompleto,
        client.telefono,
        client.documentoIdentidad ?? '',
      ];

      return values.any((value) => _normalize(value).contains(query));
    }).toList();
  }

  void loadClients() {
    _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _clientRepository.watchActiveClients().listen(
      (clients) {
        _clients = clients;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'No fue posible cargar los clientes.';
        notifyListeners();
      },
    );
  }

  void search(String value) {
    _searchText = value;
    notifyListeners();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
