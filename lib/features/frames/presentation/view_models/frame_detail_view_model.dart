import 'package:flutter/foundation.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class FrameDetailViewModel extends ChangeNotifier {
  FrameDetailViewModel({
    required FrameRepository frameRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required String frameId,
  }) : _frameRepository = frameRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _frameId = frameId;

  final FrameRepository _frameRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final String _frameId;

  bool _isLoading = false;
  bool _isChangingAvailability = false;
  bool _isDeactivating = false;
  bool _canManage = false;

  Frame? _frame;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isChangingAvailability => _isChangingAvailability;
  bool get isDeactivating => _isDeactivating;
  bool get canManage => _canManage;

  Frame? get frame => _frame;
  String? get errorMessage => _errorMessage;

  Future<void> loadFrame() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _frame = await _frameRepository.getFrameById(_frameId);

      final uid = _authRepository.currentUserId;

      if (uid != null) {
        try {
          final profile = await _userRepository.getUserById(uid);

          _canManage = profile.rol == UserRole.administrador;
        } catch (_) {
          _canManage = false;
        }
      } else {
        _canManage = false;
      }
    } on FrameException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al cargar la montura.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changeAvailability() async {
    final currentFrame = _frame;

    if (!_canManage || currentFrame == null || _isChangingAvailability) {
      return false;
    }

    _isChangingAvailability = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _frameRepository.setAvailability(
        frameId: _frameId,
        disponible: !currentFrame.disponible,
      );

      _frame = await _frameRepository.getFrameById(_frameId);

      return true;
    } on FrameException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage =
          'Ocurrió un error inesperado al cambiar la disponibilidad.';
      return false;
    } finally {
      _isChangingAvailability = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateFrame() async {
    if (!_canManage || _isDeactivating) {
      return false;
    }

    _isDeactivating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _frameRepository.deactivateFrame(_frameId);

      return true;
    } on FrameException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado al desactivar la montura.';
      return false;
    } finally {
      _isDeactivating = false;
      notifyListeners();
    }
  }
}
