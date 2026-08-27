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
  });

  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? documentoIdentidad;
  final String? fotoFacialUrl;
  final DateTime fechaRegistro;
  final bool activo;

  String get nombreCompleto {
    return '$nombres $apellidos'.trim();
  }
}
