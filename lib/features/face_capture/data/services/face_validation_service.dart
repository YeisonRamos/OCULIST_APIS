import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:oculist/features/face_capture/domain/models/face_validation_result.dart';

class FaceValidationService {
  FaceValidationService()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: .15,
        ),
      );

  final FaceDetector _detector;

  Future<FaceValidationResult> validate({
    required String imagePath,
    required Uint8List bytes,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) {
      return const FaceValidationResult.invalid(
        'No se detectó un rostro. Centra tu cara dentro del óvalo e inténtalo nuevamente.',
      );
    }
    if (faces.length > 1) {
      return const FaceValidationResult.invalid(
        'Se detectó más de un rostro. Solo una persona debe aparecer en la fotografía.',
      );
    }

    final dimensions = await _imageDimensions(bytes);
    final face = faces.single;
    final widthRatio = face.boundingBox.width / dimensions.width;
    final heightRatio = face.boundingBox.height / dimensions.height;

    if (widthRatio < .24 || heightRatio < .24) {
      return const FaceValidationResult.invalid(
        'El rostro está muy lejos. Acércate un poco y mantén toda la cara dentro del óvalo.',
      );
    }

    final pitch = face.headEulerAngleX?.abs() ?? 0;
    final yaw = face.headEulerAngleY?.abs() ?? 0;
    final roll = face.headEulerAngleZ?.abs() ?? 0;
    if (pitch > 20 || yaw > 20 || roll > 16) {
      return const FaceValidationResult.invalid(
        'Mira de frente a la cámara y mantén la cabeza recta.',
      );
    }

    return const FaceValidationResult.valid();
  }

  Future<ui.Size> _imageDimensions(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      final size = ui.Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      return size;
    } finally {
      codec.dispose();
    }
  }

  Future<void> close() => _detector.close();
}
