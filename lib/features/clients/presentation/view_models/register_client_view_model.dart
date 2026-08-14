import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';

class RegisterClientViewModel extends ChangeNotifier {
  RegisterClientViewModel({required ClientRepository clientRepository})
    : _clientRepository = clientRepository;

  final ClientRepository _clientRepository;

  bool _isSaving = false;
  String? _errorMessage;
  Client? _createdClient;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Client? get createdClient => _createdClient;

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

  Future<bool> registerClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    if (_isSaving) {
      return false;
    }

    _errorMessage = null;
    _createdClient = null;
    _setSaving(true);

    try {
      _createdClient = await _clientRepository.createClient(
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
      _errorMessage = 'Ocurrió un error inesperado al registrar al cliente.';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    if (_isSaving == value) {
      return;
    }

    _isSaving = value;
    notifyListeners();
  }
}
