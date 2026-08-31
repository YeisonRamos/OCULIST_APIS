import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';
import 'package:oculist/features/face_capture/domain/models/face_validation_result.dart';

class FaceValidationService {
  FaceValidationService()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: .15,
          enableContours: true,
          enableLandmarks: true,
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
    if (metrics.sharpness < 2.2) {
      return const FaceValidationResult.invalid(
        'La fotografía está demasiado borrosa. Limpie la cámara, mantenga el teléfono firme e inténtelo nuevamente.',
      );
    }

    final shape = _classifyFaceShape(face);
    final geometry = _extractGeometry(face, metrics.size);
    if (geometry == null) {
      return const FaceValidationResult.invalid(
        'No se localizaron ambos ojos. Mire al frente y retire cualquier objeto que cubra el rostro.',
      );
    }
    return FaceValidationResult.valid(shape, geometry);
  }

  FaceGeometry? _extractGeometry(Face face, ui.Size imageSize) {
    final left = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final right = face.landmarks[FaceLandmarkType.rightEye]?.position;
    if (left == null || right == null) return null;
    return FaceGeometry(
      leftEyeX: left.x / imageSize.width,
      leftEyeY: left.y / imageSize.height,
      rightEyeX: right.x / imageSize.width,
      rightEyeY: right.y / imageSize.height,
      imageWidth: imageSize.width,
      imageHeight: imageSize.height,
    );
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

  FaceShape _classifyFaceShape(Face face) {
    final points = face.contours[FaceContourType.face]?.points;
    if (points == null || points.length < 12) {
      return _shapeFromBoundingBox(face);
    }

    final minX = points.map((point) => point.x).reduce(math.min).toDouble();
    final maxX = points.map((point) => point.x).reduce(math.max).toDouble();
    final minY = points.map((point) => point.y).reduce(math.min).toDouble();
    final maxY = points.map((point) => point.y).reduce(math.max).toDouble();
    final width = maxX - minX;
    final height = maxY - minY;
    if (width <= 0 || height <= 0) return _shapeFromBoundingBox(face);

    double widthAt(double verticalPosition) {
      final tolerance = height * .13;
      final targetY = minY + height * verticalPosition;
      final band = points.where(
        (point) => (point.y - targetY).abs() <= tolerance,
      );
      if (band.length < 2) return width;
      final bandMin = band.map((point) => point.x).reduce(math.min);
      final bandMax = band.map((point) => point.x).reduce(math.max);
      return (bandMax - bandMin).toDouble();
    }

    final foreheadWidth = widthAt(.22);
    final cheekWidth = widthAt(.48);
    final jawWidth = widthAt(.76);
    final aspectRatio = height / width;

    if (aspectRatio >= 1.48) return FaceShape.oblong;
    if (foreheadWidth > jawWidth * 1.13) return FaceShape.heart;
    if (jawWidth > foreheadWidth * 1.13) return FaceShape.triangular;

    final balancedSides = (foreheadWidth - jawWidth).abs() / width < .10;
    if (balancedSides && aspectRatio <= 1.20) return FaceShape.round;
    if (balancedSides && jawWidth >= cheekWidth * .88) {
      return FaceShape.square;
    }
    return FaceShape.oval;
  }

  FaceShape _shapeFromBoundingBox(Face face) {
    final ratio = face.boundingBox.height / face.boundingBox.width;
    if (ratio >= 1.48) return FaceShape.oblong;
    if (ratio <= 1.18) return FaceShape.round;
    return FaceShape.oval;
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
