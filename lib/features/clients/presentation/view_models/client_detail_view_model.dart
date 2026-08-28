import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class ClientDetailViewModel extends ChangeNotifier {
  ClientDetailViewModel({
    required ClientRepository clientRepository,
    required String clientId,
  }) : _clientRepository = clientRepository,
       _clientId = clientId;

  final ClientRepository _clientRepository;
  final String _clientId;

  bool _isLoading = false;
  bool _isDeactivating = false;
  bool _isSavingPhoto = false;
  Client? _client;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isDeactivating => _isDeactivating;
  bool get isSavingPhoto => _isSavingPhoto;
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

  Future<bool> saveFacePhoto({
    required String filePath,
    required FaceShape faceShape,
    required FaceGeometry faceGeometry,
  }) async {
    if (_isSavingPhoto) {
      return false;
    }

    _isSavingPhoto = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photoUrl = await _clientRepository.saveFacePhoto(
        clientId: _clientId,
        filePath: filePath,
        faceShape: faceShape,
        faceGeometry: faceGeometry,
      );
      final currentClient = _client;
      if (currentClient != null) {
        _client = Client(
          id: currentClient.id,
          nombres: currentClient.nombres,
          apellidos: currentClient.apellidos,
          telefono: currentClient.telefono,
          documentoIdentidad: currentClient.documentoIdentidad,
          fechaRegistro: currentClient.fechaRegistro,
          activo: currentClient.activo,
          fotoFacialUrl: photoUrl,
          tipoRostro: faceShape,
          geometriaFacial: faceGeometry,
        );
      }
      return true;
    } on ClientException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al guardar la fotografía.';
      return false;
    } finally {
      _isSavingPhoto = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateClient() async {
    if (_isDeactivating) {
      return false;
    }

    _isDeactivating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _clientRepository.deactivateClient(_clientId);
      return true;
    } on ClientException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al desactivar al cliente.';
      return false;
    } finally {
      _isDeactivating = false;
      notifyListeners();
    }
  }
}
