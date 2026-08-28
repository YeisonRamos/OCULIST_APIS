import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';

class Client {
  const Client({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.fechaRegistro,
    required this.activo,
    this.documentoIdentidad,
    this.fotoFacialUrl,
    this.tipoRostro,
    this.geometriaFacial,
  });

  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? documentoIdentidad;
  final String? fotoFacialUrl;
  final FaceShape? tipoRostro;
  final FaceGeometry? geometriaFacial;
  final DateTime fechaRegistro;
  final bool activo;

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
