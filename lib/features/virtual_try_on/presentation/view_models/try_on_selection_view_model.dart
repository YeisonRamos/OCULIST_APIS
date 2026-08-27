import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class TryOnSelectionViewModel extends ChangeNotifier {
  TryOnSelectionViewModel({
    required ClientRepository clientRepository,
    required FrameRepository frameRepository,
    required String clientId,
  }) : _clientRepository = clientRepository,
       _frameRepository = frameRepository,
       _clientId = clientId;

  final ClientRepository _clientRepository;
  final FrameRepository _frameRepository;
  final String _clientId;

  StreamSubscription<List<Frame>>? _subscription;
  Client? _client;
  List<Frame> _frames = [];
  Frame? _selectedFrame;
  String _searchText = '';
  bool _isLoading = true;
  String? _errorMessage;

  Client? get client => _client;
  Frame? get selectedFrame => _selectedFrame;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Frame> get filteredFrames {
    final query = _normalize(_searchText);
    final availableFrames = _frames.where((frame) => frame.disponible);
    if (query.isEmpty) return List.unmodifiable(availableFrames);

    return availableFrames.where((frame) {
      return [
        frame.codigo,
        frame.marca,
        frame.modelo,
        frame.color,
        frame.forma,
      ].any((value) => _normalize(value).contains(query));
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _client = await _clientRepository.getClientById(_clientId);
      await _subscription?.cancel();
      _subscription = _frameRepository.watchActiveFrames().listen(
        (frames) {
          _frames = frames;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (_) {
          _isLoading = false;
          _errorMessage = 'No fue posible cargar las monturas disponibles.';
          notifyListeners();
        },
      );
    } on ClientException catch (error) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'No fue posible preparar el probador virtual.';
      notifyListeners();
    }
  }

  void search(String value) {
    _searchText = value;
    notifyListeners();
  }

  void selectFrame(Frame frame) {
    _selectedFrame = frame;
    notifyListeners();
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
