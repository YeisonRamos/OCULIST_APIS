import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class FaceValidationResult {
  const FaceValidationResult._({
    required this.isValid,
    required this.message,
    this.faceShape,
    this.faceGeometry,
  });

  const FaceValidationResult.valid(FaceShape shape, FaceGeometry geometry)
    : this._(
        isValid: true,
        message: 'Rostro detectado correctamente.',
        faceShape: shape,
        faceGeometry: geometry,
      );

  const FaceValidationResult.invalid(String message)
    : this._(isValid: false, message: message);

  final bool isValid;
  final String message;
  final FaceShape? faceShape;
  final FaceGeometry? faceGeometry;
}
