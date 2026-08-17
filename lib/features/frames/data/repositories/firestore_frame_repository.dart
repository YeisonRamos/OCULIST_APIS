import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oculist/features/frames/data/services/firestore_frame_service.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class FirestoreFrameRepository implements FrameRepository {
  FirestoreFrameRepository({required FirestoreFrameService frameService})
    : _frameService = frameService;

  final FirestoreFrameService _frameService;

  @override
  Future<Frame> createFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    String? imagenUrl,
  }) async {
    final cleanCode = codigo.trim();
    final cleanBrand = marca.trim();
    final cleanModel = modelo.trim();
    final cleanColor = color.trim();
    final cleanShape = forma.trim();
    final cleanMaterial = material.trim();
    final cleanSize = talla.trim();
    final cleanImageUrl = imagenUrl?.trim();

    try {
      final id = await _frameService.createFrame(
        codigo: cleanCode,
        marca: cleanBrand,
        modelo: cleanModel,
        color: cleanColor,
        forma: cleanShape,
        material: cleanMaterial,
        talla: cleanSize,
        imagenUrl: cleanImageUrl?.isEmpty == true ? null : cleanImageUrl,
      );

      return Frame(
        id: id,
        codigo: cleanCode,
        marca: cleanBrand,
        modelo: cleanModel,
        color: cleanColor,
        forma: cleanShape,
        material: cleanMaterial,
        talla: cleanSize,
        imagenUrl: cleanImageUrl?.isEmpty == true ? null : cleanImageUrl,
        disponible: true,
        activo: true,
        fechaRegistro: DateTime.now(),
      );
    } on FirebaseException {
      throw const FrameException('No fue posible registrar la montura.');
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error inesperado al registrar la montura.',
      );
    }
  }

  @override
  Stream<List<Frame>> watchActiveFrames() {
    return _frameService.watchActiveFrames().map((snapshot) {
      final frames = snapshot.docs.map((document) {
        final data = document.data();
        final timestamp = data['fechaRegistro'];

        return Frame(
          id: document.id,
          codigo: data['codigo'] as String? ?? '',
          marca: data['marca'] as String? ?? '',
          modelo: data['modelo'] as String? ?? '',
          color: data['color'] as String? ?? '',
          forma: data['forma'] as String? ?? '',
          material: data['material'] as String? ?? '',
          talla: data['talla'] as String? ?? '',
          imagenUrl: data['imagenUrl'] as String?,
          disponible: data['disponible'] as bool? ?? false,
          activo: data['activo'] as bool? ?? false,
          fechaRegistro: timestamp is Timestamp
              ? timestamp.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0),
        );
      }).toList();

      frames.sort((a, b) => a.codigo.compareTo(b.codigo));

      return frames;
    });
  }
}
