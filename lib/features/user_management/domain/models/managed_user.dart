class ManagedUser {
  const ManagedUser({
    required this.uid,
    required this.nombreCompleto,
    required this.correo,
    required this.activo,
    this.fechaRegistro,
  });

  final String uid;
  final String nombreCompleto;
  final String correo;
  final bool activo;
  final DateTime? fechaRegistro;
}
