import 'json_utils.dart';

/// Usuario del endpoint `/users` de JSONPlaceholder.
///
/// Es el modelo del ejemplo guiado de la práctica.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: leerEntero(json, 'id'),
    nombre: leerTexto(json, 'name'),
    correo: leerTexto(json, 'email'),
  );

  final int id;
  final String nombre;
  final String correo;

  @override
  bool operator ==(Object other) =>
      other is Usuario &&
      other.id == id &&
      other.nombre == nombre &&
      other.correo == correo;

  @override
  int get hashCode => Object.hash(id, nombre, correo);

  @override
  String toString() => 'Usuario(id: $id, nombre: $nombre)';
}
