import 'dart:math' as math;
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
    final faces = await _detector.processImage(
      InputImage.fromFilePath(imagePath),
    );

    if (faces.isEmpty) {
      return const FaceValidationResult.invalid(
        'No se detectó un rostro. Coloque la cara dentro del óvalo.',
      );
    }
    if (faces.length > 1) {
      return const FaceValidationResult.invalid(
        'Se detectó más de un rostro. Solo una persona debe aparecer en la fotografía.',
      );
    }

    final metrics = await _analyzeImage(bytes);
    final face = faces.single;
    final widthRatio = face.boundingBox.width / metrics.size.width;
    final heightRatio = face.boundingBox.height / metrics.size.height;

    if (widthRatio < .26 || heightRatio < .26) {
      return const FaceValidationResult.invalid(
        'Acérquese un poco a la cámara.',
      );
    }
    if (widthRatio > .82 || heightRatio > .82) {
      return const FaceValidationResult.invalid(
        'Aléjese un poco para que el rostro quede completo.',
      );
    }

    final centerX = face.boundingBox.center.dx / metrics.size.width;
    final centerY = face.boundingBox.center.dy / metrics.size.height;
    if (centerY > .62) {
      return const FaceValidationResult.invalid('Suba un poco la cabeza.');
    }
    if (centerY < .30) {
      return const FaceValidationResult.invalid('Baje un poco la cabeza.');
    }
    if (centerX < .35) {
      return const FaceValidationResult.invalid(
        'Muévase un poco hacia la derecha.',
      );
    }
    if (centerX > .65) {
      return const FaceValidationResult.invalid(
        'Muévase un poco hacia la izquierda.',
      );
    }

    final pitch = face.headEulerAngleX?.abs() ?? 0;
    final yaw = face.headEulerAngleY?.abs() ?? 0;
    final roll = face.headEulerAngleZ?.abs() ?? 0;
    if (pitch > 18 || yaw > 18 || roll > 14) {
      return const FaceValidationResult.invalid(
        'Mire al frente y mantenga la cabeza recta.',
      );
    }

    if (metrics.brightness < 48) {
      return const FaceValidationResult.invalid(
        'La fotografía está muy oscura. Busque un lugar con más luz.',
      );
    }
    if (metrics.brightness > 225) {
      return const FaceValidationResult.invalid(
        'Hay demasiada luz. Evite colocarse frente a una luz intensa.',
      );
    }
    if (metrics.sharpness < 7) {
      return const FaceValidationResult.invalid(
        'La fotografía está borrosa. Mantenga el teléfono firme e inténtelo nuevamente.',
      );
    }

    return const FaceValidationResult.valid();
  }

  Future<_ImageMetrics> _analyzeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (data == null) {
          throw StateError('No fue posible analizar la calidad de la imagen.');
        }

        final width = image.width;
        final height = image.height;
        final pixels = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        final step = math.max(1, math.min(width, height) ~/ 220);
        var brightnessSum = 0.0;
        var edgeSum = 0.0;
        var samples = 0;

        for (var y = 0; y < height - step; y += step) {
          for (var x = 0; x < width - step; x += step) {
            final current = _luminance(pixels, (y * width + x) * 4);
            final right = _luminance(pixels, (y * width + x + step) * 4);
            final below = _luminance(pixels, ((y + step) * width + x) * 4);
            brightnessSum += current;
            edgeSum += (current - right).abs() + (current - below).abs();
            samples++;
          }
        }

        if (samples == 0) {
          throw StateError('La fotografía no tiene un tamaño válido.');
        }

        return _ImageMetrics(
          size: ui.Size(width.toDouble(), height.toDouble()),
          brightness: brightnessSum / samples,
          sharpness: edgeSum / (samples * 2),
        );
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  double _luminance(Uint8List pixels, int index) {
    return pixels[index] * .299 +
        pixels[index + 1] * .587 +
        pixels[index + 2] * .114;
  }

  Future<void> close() => _detector.close();
}

class _ImageMetrics {
  const _ImageMetrics({
    required this.size,
    required this.brightness,
    required this.sharpness,
  });

  final ui.Size size;
  final double brightness;
  final double sharpness;
}
