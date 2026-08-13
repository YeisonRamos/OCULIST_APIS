enum UserRole { optico, administrador }

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
  });

  final String uid;
  final String nombre;
  final String correo;
  final UserRole rol;
  final bool activo;
}
