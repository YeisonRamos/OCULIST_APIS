import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/face_capture/data/services/face_validation_service.dart';
import 'package:oculist/features/face_capture/domain/models/face_capture_result.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class FaceCaptureView extends StatefulWidget {
  const FaceCaptureView({super.key});

  @override
  State<FaceCaptureView> createState() => _FaceCaptureViewState();
}

class _FaceCaptureViewState extends State<FaceCaptureView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  XFile? _capturedImage;
  Uint8List? _capturedBytes;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isValidating = false;
  String? _errorMessage;
  FaceShape? _detectedShape;
  final FaceValidationService _validationService = FaceValidationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'cameraNotFound',
          'No se encontró una cámara disponible.',
        );
      }

      final frontCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      final selectedCamera = frontCameras.isNotEmpty
          ? frontCameras.first
          : cameras.first;
      final previousController = _controller;
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _controller = controller;
      await previousController?.dispose();
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _isInitializing = false);
    } on CameraException catch (error) {
      _showCameraError(_messageForCameraError(error));
    } catch (_) {
      _showCameraError('No fue posible iniciar la cámara.');
    }
  }

  void _showCameraError(String message) {
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _errorMessage = message;
    });
  }

  String _messageForCameraError(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Permiso de cámara denegado. Actívalo desde los ajustes del dispositivo.';
      case 'CameraAccessRestricted':
        return 'El acceso a la cámara está restringido en este dispositivo.';
      default:
        return error.description ?? 'No fue posible iniciar la cámara.';
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _isValidating = true);
      final result = await _validationService.validate(
        imagePath: image.path,
        bytes: bytes,
      );
      if (!mounted) return;
      if (!result.isValid) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.face_retouching_off_rounded),
            title: const Text('Fotografía no válida'),
            content: Text(result.message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _capturedImage = image;
        _capturedBytes = bytes;
        _detectedShape = result.faceShape;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForCameraError(error))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible analizar la fotografía. Inténtelo nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _isValidating = false;
        });
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _capturedBytes = null;
      _detectedShape = null;
    });
  }

  void _usePhoto() {
    final path = _capturedImage?.path;
    final shape = _detectedShape;
    if (path != null && shape != null) {
      Navigator.of(
        context,
      ).pop(FaceCaptureResult(imagePath: path, faceShape: shape));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _validationService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedBytes != null) return _buildConfirmation();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fotografía facial'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildCameraBody(),
    );
  }

  Widget _buildCameraBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.orange),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 18),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: CameraPreview(controller)),
        const IgnorePointer(child: CustomPaint(painter: _FaceGuidePainter())),
        Positioned(
          top: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .58),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Centra el rostro dentro del óvalo y mira de frente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (_isValidating)
          ColoredBox(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.orange),
                  SizedBox(height: 16),
                  Text(
                    'Analizando rostro...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 34,
          child: Center(
            child: Semantics(
              button: true,
              label: 'Capturar fotografía',
              child: GestureDetector(
                onTap: (_isCapturing || _isValidating) ? null : _capturePhoto,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .28),
                    shape: BoxShape.circle,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _isCapturing ? AppTheme.orange : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.crimson, width: 4),
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: AppTheme.crimson,
                            size: 34,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Revisar fotografía'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.memory(
                  _capturedBytes!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: const BoxDecoration(
                color: AppTheme.warmWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Repetir'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _usePhoto,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Usar fotografía'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .44),
      width: size.width * .68,
      height: size.height * .52,
    );
    final overlayPath = Path()
      ..addRect(Offset.zero & size)
      ..addOval(oval)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: .48),
    );
    canvas.drawOval(
      oval,
      Paint()
        ..color = AppTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
