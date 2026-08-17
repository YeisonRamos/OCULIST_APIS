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
}
