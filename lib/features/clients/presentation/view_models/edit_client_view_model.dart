import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class EditClientViewModel extends ChangeNotifier {
  EditClientViewModel({
    required ClientRepository clientRepository,
    required String clientId,
  }) : _clientRepository = clientRepository,
       _clientId = clientId;

  final ClientRepository _clientRepository;
  final String _clientId;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Client? _client;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Client? get client => _client;

  String? validateNames(String? value) {
    final names = value?.trim() ?? '';

    if (names.isEmpty) {
      return 'Ingresa los nombres del cliente';
    }

    if (names.length < 2) {
      return 'Ingresa nombres válidos';
    }

    return null;
  }

  String? validateLastNames(String? value) {
    final lastNames = value?.trim() ?? '';

    if (lastNames.isEmpty) {
      return 'Ingresa los apellidos del cliente';
    }

    if (lastNames.length < 2) {
      return 'Ingresa apellidos válidos';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Ingresa el teléfono del cliente';
    }

    final phonePattern = RegExp(r'^[0-9+\-\s]{7,20}$');

    if (!phonePattern.hasMatch(phone)) {
      return 'Ingresa un número de teléfono válido';
    }

    return null;
  }

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

  Future<bool> updateClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _client = await _clientRepository.updateClient(
        clientId: _clientId,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        documentoIdentidad: documentoIdentidad,
      );

      return true;
    } on ClientException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al actualizar al cliente.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
