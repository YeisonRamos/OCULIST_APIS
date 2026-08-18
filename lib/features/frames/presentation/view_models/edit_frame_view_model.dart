import 'package:flutter/foundation.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class EditFrameViewModel extends ChangeNotifier {
  EditFrameViewModel({
    required FrameRepository frameRepository,
    required String frameId,
  }) : _frameRepository = frameRepository,
       _frameId = frameId;

  final FrameRepository _frameRepository;
  final String _frameId;

  bool _isLoading = false;
  bool _isSaving = false;
  Frame? _frame;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  Frame? get frame => _frame;
  String? get errorMessage => _errorMessage;

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $fieldName';
    }

    return null;
  }

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

  Future<bool> updateFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _frame = await _frameRepository.updateFrame(
        frameId: _frameId,
        codigo: codigo,
        marca: marca,
        modelo: modelo,
        color: color,
        forma: forma,
        material: material,
        talla: talla,
      );

      return true;
    } on FrameException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al actualizar la montura.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
