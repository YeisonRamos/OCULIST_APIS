import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class FaceCaptureResult {
  const FaceCaptureResult({
    required this.imagePath,
    required this.faceShape,
    required this.faceGeometry,
  });

  final String imagePath;
  final FaceShape faceShape;
  final FaceGeometry faceGeometry;
}
