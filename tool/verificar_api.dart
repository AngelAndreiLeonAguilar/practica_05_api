// Comprobación manual contra la API real de Wikipedia en español.
//
// Uso:
//   dart run tool/verificar_api.dart
import 'package:practica_05_api/models/articulo.dart';
import 'package:practica_05_api/services/api_exception.dart';
import 'package:practica_05_api/services/wikipedia_api.dart';

Future<void> main() async {
  final api = WikipediaApi();
  try {
    final articulos = await api.buscar('México', limite: 5);
    print('Artículos recibidos: ${articulos.length}');
    for (final Articulo a in articulos) {
      print('- ${a.titulo} (${a.id}): ${a.resumen}');
    }
  } on ApiException catch (e) {
    print('Fallo de API: ${e.mensaje}');
  } finally {
    api.dispose();
  }
}
