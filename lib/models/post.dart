import 'json_utils.dart';

/// Publicación del endpoint `/posts` de JSONPlaceholder.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.cuerpo,
  });

  /// Crea un [Post] a partir del mapa JSON recibido del API.
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: leerEntero(json, 'id'),
    userId: leerEntero(json, 'userId'),
    titulo: leerTexto(json, 'title'),
    cuerpo: leerTexto(json, 'body'),
  );

  final int id;
  final int userId;
  final String titulo;
  final String cuerpo;

  /// Texto corto para la vista de lista.
  String get resumen => cuerpo.replaceAll('\n', ' ').trim();

  @override
  bool operator ==(Object other) =>
      other is Post &&
      other.id == id &&
      other.userId == userId &&
      other.titulo == titulo &&
      other.cuerpo == cuerpo;

  @override
  int get hashCode => Object.hash(id, userId, titulo, cuerpo);

  @override
  String toString() => 'Post(id: $id, titulo: $titulo)';
}
