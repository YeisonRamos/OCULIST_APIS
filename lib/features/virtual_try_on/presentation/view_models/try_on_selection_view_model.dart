import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/clients/domain/exceptions/client_exception.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';
import 'package:oculist/features/recommendation_rules/data/services/firestore_recommendation_rule_service.dart';
import 'package:oculist/features/recommendation_rules/domain/models/recommendation_weights.dart';
import 'package:oculist/features/virtual_try_on/domain/models/recommendation_preferences.dart';

class TryOnSelectionViewModel extends ChangeNotifier {
  TryOnSelectionViewModel({
    required ClientRepository clientRepository,
    required FrameRepository frameRepository,
    required String clientId,
    FirestoreRecommendationRuleService? ruleService,
  }) : _clientRepository = clientRepository,
       _frameRepository = frameRepository,
       _clientId = clientId,
       _ruleService = ruleService;

  final ClientRepository _clientRepository;
  final FrameRepository _frameRepository;
  final FirestoreRecommendationRuleService? _ruleService;
  final String _clientId;
  StreamSubscription<List<Frame>>? _subscription;
  Client? _client;
  List<Frame> _recommendations = [];
  List<Frame> _availableFrames = [];
  RecommendationPreferences _preferences = const RecommendationPreferences();
  RecommendationWeights _weights = const RecommendationWeights();
  bool _isLoading = true;
  String? _errorMessage;

  Client? get client => _client;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendationPreferences get preferences => _preferences;
  Frame? get primaryRecommendation =>
      _recommendations.isEmpty ? null : _recommendations.first;
  List<Frame> get alternativeRecommendations => _recommendations.length <= 1
      ? const []
      : List.unmodifiable(_recommendations.skip(1).take(2));
  List<Frame> get recommendations =>
      List.unmodifiable(_recommendations.take(3));

  void updatePreferences({String? size, String? color, String? style}) {
    _preferences = RecommendationPreferences(
      size: size ?? _preferences.size,
      color: color ?? _preferences.color,
      style: style ?? _preferences.style,
    );
    if (_client?.tipoRostro != null) {
      _recommendations = _rankFrames(_availableFrames, _client!.tipoRostro!);
    }
    notifyListeners();
  }

  String explanationFor(Frame frame) {
    final reasons = <String>[];
    if (_shapeScore(frame, _preferredShapes(_client!.tipoRostro!)) > 0) {
      reasons.add('su forma favorece un rostro ${_client!.tipoRostro!.label}');
    }
    if (_preferences.size.isNotEmpty &&
        _sizeMatches(frame.talla, _preferences.size)) {
      reasons.add('coincide con la talla elegida');
    }
    if (_preferences.color.isNotEmpty &&
        _matches(frame.color, _preferences.color)) {
      reasons.add('coincide con el color preferido');
    }
    if (_preferences.style.isNotEmpty &&
        _matches(frame.estilo, _preferences.style)) {
      reasons.add('coincide con el estilo preferido');
    }
    return reasons.isEmpty
        ? 'Recomendada por disponibilidad y compatibilidad general.'
        : 'Recomendada porque ${reasons.join(', ')}.';
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _client = await _clientRepository.getClientById(_clientId);
      if (_client?.tipoRostro == null || _client?.geometriaFacial == null) {
        _isLoading = false;
        _errorMessage =
            'El cliente necesita un anÃ¡lisis facial antes de recibir recomendaciones.';
        notifyListeners();
        return;
      }
      try {
        _weights = await (_ruleService ?? FirestoreRecommendationRuleService())
            .getWeights();
      } catch (_) {
        _weights = const RecommendationWeights();
      }
      await _subscription?.cancel();
      _subscription = _frameRepository.watchActiveFrames().listen(
        (frames) {
          _availableFrames = frames.where((frame) => frame.disponible).toList();
          _recommendations = _rankFrames(
            _availableFrames,
            _client!.tipoRostro!,
          );
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (_) {
          _isLoading = false;
          _errorMessage = 'No fue posible consultar el catÃ¡logo de monturas.';
          notifyListeners();
        },
      );
    } on ClientException catch (error) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'No fue posible generar la recomendaciÃ³n.';
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
    var score = _shapeScore(frame, preferred);
    if (_preferences.size.isNotEmpty &&
        _sizeMatches(frame.talla, _preferences.size)) {
      score += _weights.size;
    }
    if (_preferences.color.isNotEmpty &&
        _matches(frame.color, _preferences.color)) {
      score += _weights.color;
    }
    if (_preferences.style.isNotEmpty &&
        _matches(frame.estilo, _preferences.style)) {
      score += _weights.style;
    }
    return score;
  }

  int _shapeScore(Frame frame, List<String> preferred) {
    final value = _normalize(frame.forma);
    for (var index = 0; index < preferred.length; index++) {
      if (value.contains(preferred[index])) {
        final relevance = 1 - (index * 0.12);
        return (_weights.shape * relevance.clamp(0.4, 1)).round();
      }
    }
    return 0;
  }

  bool _matches(String value, String preference) {
    final first = _normalize(value);
    final second = _normalize(preference);
    return first.contains(second) || second.contains(first);
  }

  bool _sizeMatches(String value, String preference) {
    String canonical(String input) {
      final normalized = _normalize(input);
      if (normalized.startsWith('p') || normalized == 's') return 'pequena';
      if (normalized.startsWith('m')) return 'mediana';
      if (normalized.startsWith('g') || normalized == 'l') return 'grande';
      return normalized;
    }

    return canonical(value) == canonical(preference);
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
      .replaceAll('Ã¡', 'a')
      .replaceAll('Ã©', 'e')
      .replaceAll('Ã­', 'i')
      .replaceAll('Ã³', 'o')
      .replaceAll('Ãº', 'u')
      .replaceAll('Ã±', 'n');

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
