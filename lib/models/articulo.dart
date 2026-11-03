import 'json_utils.dart';

/// Artículo de la Wikipedia en español (API `es.wikipedia.org`).
class Articulo {
  const Articulo({
    required this.id,
    required this.titulo,
    required this.extracto,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) => Articulo(
    id: leerEntero(json, 'pageid'),
    titulo: leerTexto(json, 'title'),
    extracto: leerTexto(json, 'extract'),
  );

  final int id;
  final String titulo;
  final String extracto;

  /// Texto corto de una sola línea para la vista de lista.
  String get resumen {
    final limpio = extracto.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (limpio.length <= 180) return limpio;
    return '${limpio.substring(0, 180)}…';
  }

  @override
  bool operator ==(Object other) =>
      other is Articulo &&
      other.id == id &&
      other.titulo == titulo &&
      other.extracto == extracto;

  @override
  int get hashCode => Object.hash(id, titulo, extracto);

  @override
  String toString() => 'Articulo(id: $id, titulo: $titulo)';
}
