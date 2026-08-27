import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class FaceValidationResult {
  const FaceValidationResult._({
    required this.isValid,
    required this.message,
    this.faceShape,
  });

  const FaceValidationResult.valid(FaceShape shape)
    : this._(
        isValid: true,
        message: 'Rostro detectado correctamente.',
        faceShape: shape,
      );

  const FaceValidationResult.invalid(String message)
    : this._(isValid: false, message: message);

  final bool isValid;
  final String message;
  final FaceShape? faceShape;
}
