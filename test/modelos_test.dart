import 'package:flutter_test/flutter_test.dart';
import 'package:practica_05_api/models/articulo.dart';
import 'package:practica_05_api/models/usuario.dart';

void main() {
  group('Articulo.fromJson', () {
    test('convierte un mapa JSON de la Wikipedia', () {
      final articulo = Articulo.fromJson(const {
        'pageid': 1830,
        'title': 'México',
        'extract': 'México, oficialmente Estados Unidos Mexicanos, es un país…',
      });

      expect(articulo.id, 1830);
      expect(articulo.titulo, 'México');
      expect(articulo.extracto, startsWith('México, oficialmente'));
    });

    test('lanza FormatException si falta el extracto', () {
      expect(
        () => Articulo.fromJson(const {'pageid': 1, 'title': 'Sin cuerpo'}),
        throwsFormatException,
      );
    });

    test('lanza FormatException si el pageid no es numérico', () {
      expect(
        () => Articulo.fromJson(const {
          'pageid': 'uno',
          'title': 'T',
          'extract': 'E',
        }),
        throwsFormatException,
      );
    });

    test('el resumen colapsa espacios y recorta a 180 caracteres', () {
      final largo = 'palabra ${'x' * 400}';
      final articulo = Articulo.fromJson({
        'pageid': 2,
        'title': 'Largo',
        'extract': '  hola   mundo \n con   espacios $largo',
      });

      expect(articulo.resumen, startsWith('hola mundo con espacios'));
      expect(articulo.resumen.contains('\n'), isFalse);
      expect(articulo.resumen.length, lessThanOrEqualTo(181));
      expect(articulo.resumen.endsWith('…'), isTrue);
    });

    test('igualdad por valor', () {
      const a = Articulo(id: 1, titulo: 'A', extracto: 'E');
      const b = Articulo(id: 1, titulo: 'A', extracto: 'E');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Usuario.fromJson', () {
    test('convierte el JSON de /users', () {
      final usuario = Usuario.fromJson(const {
        'id': 3,
        'name': 'Ana',
        'email': 'ana@example.com',
      });

      expect(usuario.id, 3);
      expect(usuario.nombre, 'Ana');
      expect(usuario.correo, 'ana@example.com');
    });

    test('lanza FormatException si el correo no es texto', () {
      expect(
        () => Usuario.fromJson(const {'id': 1, 'name': 'A', 'email': 42}),
        throwsFormatException,
      );
    });
  });
}
