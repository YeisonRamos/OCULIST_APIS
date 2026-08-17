import 'package:flutter/foundation.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class FrameDetailViewModel extends ChangeNotifier {
  FrameDetailViewModel({
    required FrameRepository frameRepository,
    required String frameId,
  }) : _frameRepository = frameRepository,
       _frameId = frameId;

  final FrameRepository _frameRepository;
  final String _frameId;

  bool _isLoading = false;
  Frame? _frame;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Frame? get frame => _frame;
  String? get errorMessage => _errorMessage;

  Future<void> loadFrame() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _frame = await _frameRepository.getFrameById(_frameId);
    } on FrameException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al cargar la montura.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
