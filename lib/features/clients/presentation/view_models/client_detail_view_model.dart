import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class ClientDetailViewModel extends ChangeNotifier {
  ClientDetailViewModel({
    required ClientRepository clientRepository,
    required String clientId,
  }) : _clientRepository = clientRepository,
       _clientId = clientId;

  final ClientRepository _clientRepository;
  final String _clientId;

  bool _isLoading = false;
  Client? _client;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Client? get client => _client;
  String? get errorMessage => _errorMessage;

  Future<void> loadClient() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _client = await _clientRepository.getClientById(_clientId);
    } on ClientException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al cargar el cliente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
