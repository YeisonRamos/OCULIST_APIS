import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oculist/features/frames/data/services/firestore_frame_service.dart';
import 'package:oculist/features/frames/domain/exceptions/frame_exception.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';
import 'package:oculist/features/frames/data/services/frame_storage_service.dart';

class FirestoreFrameRepository implements FrameRepository {
  FirestoreFrameRepository({
    required FirestoreFrameService frameService,
    required FrameStorageService storageService,
  }) : _frameService = frameService,
       _storageService = storageService;

  final FirestoreFrameService _frameService;
  final FrameStorageService _storageService;

  @override
  Future<Frame> updateFrame({
    required String frameId,
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    required String estilo,
  }) async {
    final cleanCode = codigo.trim();
    final cleanBrand = marca.trim();
    final cleanModel = modelo.trim();
    final cleanColor = color.trim();
    final cleanShape = forma.trim();
    final cleanMaterial = material.trim();
    final cleanSize = talla.trim();
    final cleanStyle = estilo.trim();

    try {
      await _frameService.updateFrame(
        frameId: frameId,
        codigo: cleanCode,
        marca: cleanBrand,
        modelo: cleanModel,
        color: cleanColor,
        forma: cleanShape,
        material: cleanMaterial,
        talla: cleanSize,
        estilo: cleanStyle,
      );

      return await getFrameById(frameId);
    } on FrameException {
      rethrow;
    } on FirebaseException {
      throw const FrameException('No fue posible actualizar la montura.');
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error inesperado al actualizar la montura.',
      );
    }
  }

  @override
  Future<void> setAvailability({
    required String frameId,
    required bool disponible,
  }) async {
    try {
      await _frameService.setAvailability(
        frameId: frameId,
        disponible: disponible,
      );
    } on FirebaseException {
      throw const FrameException(
        'No fue posible cambiar la disponibilidad de la montura.',
      );
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error inesperado al cambiar la disponibilidad.',
      );
    }
  }

  @override
  Future<void> deactivateFrame(String frameId) async {
    try {
      await _frameService.deactivateFrame(frameId);
    } on FirebaseException {
      throw const FrameException('No fue posible desactivar la montura.');
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error inesperado al desactivar la montura.',
      );
    }
  }

  @override
  Future<Frame> updateFrameImage({
    required String frameId,
    required String filePath,
  }) async {
    try {
      final imageUrl = await _storageService.uploadFrameImage(
        frameId: frameId,
        filePath: filePath,
      );

      await _frameService.updateImageUrl(frameId: frameId, imageUrl: imageUrl);

      return await getFrameById(frameId);
    } on FirebaseException {
      throw const FrameException(
        'No fue posible subir la imagen de la montura.',
      );
    } on UnsupportedError {
      throw const FrameException('El formato de la imagen no es compatible.');
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error al guardar la imagen de la montura.',
      );
    }
  }

  Frame _frameFromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    if (data == null) {
      throw const FrameException(
        'Los datos de la montura no están disponibles.',
      );
    }

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
      estilo: data['estilo'] as String? ?? 'Sin definir',
      imagenUrl: data['imagenUrl'] as String?,
      disponible: data['disponible'] as bool? ?? false,
      activo: data['activo'] as bool? ?? false,
      fechaRegistro: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<Frame> createFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    required String estilo,
    String? imagenUrl,
  }) async {
    final cleanCode = codigo.trim();
    final cleanBrand = marca.trim();
    final cleanModel = modelo.trim();
    final cleanColor = color.trim();
    final cleanShape = forma.trim();
    final cleanMaterial = material.trim();
    final cleanSize = talla.trim();
    final cleanStyle = estilo.trim();
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
        estilo: cleanStyle,

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
        estilo: cleanStyle,

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
      final frames = snapshot.docs.map(_frameFromDocument).toList();

      frames.sort((a, b) => a.codigo.compareTo(b.codigo));

      return frames;
    });
  }

  @override
  Future<Frame> getFrameById(String frameId) async {
    try {
      final document = await _frameService.getFrameById(frameId);

      if (!document.exists) {
        throw const FrameException('No se encontró la montura.');
      }

      return _frameFromDocument(document);
    } on FrameException {
      rethrow;
    } on FirebaseException {
      throw const FrameException(
        'No fue posible obtener la información de la montura.',
      );
    } catch (_) {
      throw const FrameException(
        'Ocurrió un error inesperado al consultar la montura.',
      );
    }
  }
}
