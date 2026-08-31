import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';
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
  List<Frame> _recommendations = [];
  bool _isLoading = true;
  String? _errorMessage;

  Client? get client => _client;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Frame> get recommendations =>
      List.unmodifiable(_recommendations.take(3));
  Frame? get primaryRecommendation =>
      _recommendations.isEmpty ? null : _recommendations.first;
  List<Frame> get alternativeRecommendations => _recommendations.length <= 1
      ? const []
      : List.unmodifiable(_recommendations.skip(1).take(3));

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _client = await _clientRepository.getClientById(_clientId);
      if (_client?.tipoRostro == null || _client?.geometriaFacial == null) {
        _isLoading = false;
        _errorMessage =
            'El cliente necesita un análisis facial antes de recibir recomendaciones.';
        notifyListeners();
        return;
      }
      await _subscription?.cancel();
      _subscription = _frameRepository.watchActiveFrames().listen(
        (frames) {
          _recommendations = _rankFrames(
            frames.where((frame) => frame.disponible).toList(),
            _client!.tipoRostro!,
          );
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (_) {
          _isLoading = false;
          _errorMessage = 'No fue posible consultar el catálogo de monturas.';
          notifyListeners();
        },
      );
    } on ClientException catch (error) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'No fue posible generar la recomendación.';
      notifyListeners();
    }
  }

  List<Frame> _rankFrames(List<Frame> frames, FaceShape shape) {
    final preferred = _preferredShapes(shape);
    final ranked =
        frames
            .map((frame) => (frame: frame, score: _score(frame, preferred)))
            .toList()
          ..sort((a, b) {
            final comparison = b.score.compareTo(a.score);
            return comparison != 0
                ? comparison
                : a.frame.nombreCompleto.compareTo(b.frame.nombreCompleto);
          });
    return ranked.map((item) => item.frame).toList();
  }

  int _score(Frame frame, List<String> preferred) {
    final value = _normalize(frame.forma);
    for (var index = 0; index < preferred.length; index++) {
      if (value.contains(preferred[index])) return 100 - index * 10;
    }
    return 10;
  }

  List<String> _preferredShapes(FaceShape shape) {
    switch (shape) {
      case FaceShape.round:
        return ['rectang', 'cuadr', 'wayfarer', 'cat'];
      case FaceShape.square:
        return ['redond', 'oval', 'aviador'];
      case FaceShape.oval:
        return ['rectang', 'aviador', 'redond', 'cuadr', 'oval'];
      case FaceShape.oblong:
        return ['redond', 'oval', 'aviador', 'grande'];
      case FaceShape.triangular:
        return ['cat', 'aviador', 'rectang', 'oval'];
      case FaceShape.heart:
        return ['oval', 'redond', 'aviador', 'cat'];
    }
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
