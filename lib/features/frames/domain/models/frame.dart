class Frame {
  const Frame({
    required this.id,
    required this.codigo,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.forma,
    required this.material,
    required this.talla,
    required this.disponible,
    required this.activo,
    required this.fechaRegistro,
    this.imagenUrl,
  });

  final String id;
  final String codigo;
  final String marca;
  final String modelo;
  final String color;
  final String forma;
  final String material;
  final String talla;
  final String? imagenUrl;
  final bool disponible;
  final bool activo;
  final DateTime fechaRegistro;

  String get nombreCompleto {
    return '$marca $modelo'.trim();
  }
}
