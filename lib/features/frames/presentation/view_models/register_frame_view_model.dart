import 'package:flutter/foundation.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class RegisterFrameViewModel extends ChangeNotifier {
  RegisterFrameViewModel({required FrameRepository frameRepository})
    : _frameRepository = frameRepository;

  final FrameRepository _frameRepository;

  bool _isSaving = false;
  String? _errorMessage;
  Frame? _createdFrame;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Frame? get createdFrame => _createdFrame;

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $fieldName';
    }

    return null;
  }

  Future<bool> registerFrame({
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

    _errorMessage = null;
    _createdFrame = null;
    _setSaving(true);

    try {
      _createdFrame = await _frameRepository.createFrame(
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
      _errorMessage = 'Ocurrió un error inesperado al registrar la montura.';
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
