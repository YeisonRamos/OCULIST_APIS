import 'package:oculist/features/frames/domain/models/frame.dart';

abstract interface class FrameRepository {
  Future<Frame> createFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    String? imagenUrl,
  });

  Stream<List<Frame>> watchActiveFrames();

  Future<Frame> getFrameById(String frameId);

  Future<Frame> updateFrame({
    required String frameId,
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
  });

  Future<void> setAvailability({
    required String frameId,
    required bool disponible,
  });

  Future<void> deactivateFrame(String frameId);

  Future<Frame> updateFrameImage({
    required String frameId,
    required String filePath,
  });
}
