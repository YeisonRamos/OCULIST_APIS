import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class FrameListViewModel extends ChangeNotifier {
  FrameListViewModel({required FrameRepository frameRepository})
    : _frameRepository = frameRepository;

  final FrameRepository _frameRepository;

  StreamSubscription<List<Frame>>? _subscription;

  List<Frame> _frames = [];
  String _searchText = '';
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Frame> get filteredFrames {
    final query = _normalize(_searchText);

    if (query.isEmpty) {
      return List.unmodifiable(_frames);
    }

    return _frames.where((frame) {
      final values = [
        frame.codigo,
        frame.marca,
        frame.modelo,
        frame.nombreCompleto,
        frame.color,
        frame.forma,
        frame.material,
        frame.talla,
      ];

      return values.any((value) => _normalize(value).contains(query));
    }).toList();
  }

  void loadFrames() {
    _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _frameRepository.watchActiveFrames().listen(
      (frames) {
        _frames = frames;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'No fue posible cargar el catálogo de monturas.';
        notifyListeners();
      },
    );
  }

  void search(String value) {
    _searchText = value;
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
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
