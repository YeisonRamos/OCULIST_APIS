import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class FaceCaptureResult {
  const FaceCaptureResult({required this.imagePath, required this.faceShape});

  final String imagePath;
  final FaceShape faceShape;
}
