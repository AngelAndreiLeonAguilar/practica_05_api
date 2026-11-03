import 'package:flutter_test/flutter_test.dart';
import 'package:practica_05_api/models/post.dart';
import 'package:practica_05_api/models/usuario.dart';

void main() {
  group('Post.fromJson', () {
    test('convierte un mapa JSON completo', () {
      final post = Post.fromJson(const {
        'userId': 1,
        'id': 1,
        'title': 'Título de prueba',
        'body': 'Cuerpo de la publicación',
      });

      expect(post.id, 1);
      expect(post.userId, 1);
      expect(post.titulo, 'Título de prueba');
      expect(post.cuerpo, 'Cuerpo de la publicación');
    });

    test('acepta números enviados como texto', () {
      final post = Post.fromJson(const {
        'userId': '2',
        'id': '7',
        'title': 't',
        'body': 'b',
      });

      expect(post.id, 7);
      expect(post.userId, 2);
    });

    test('lanza FormatException si falta un campo', () {
      expect(
        () => Post.fromJson(const {'id': 1, 'userId': 1, 'title': 't'}),
        throwsFormatException,
      );
    });

    test('lanza FormatException si un tipo no corresponde', () {
      expect(
        () => Post.fromJson(const {
          'id': 1,
          'userId': 1,
          'title': 123,
          'body': 'b',
        }),
        throwsFormatException,
      );
    });

    test('resumen elimina saltos de línea', () {
      final post = Post.fromJson(const {
        'id': 1,
        'userId': 1,
        'title': 't',
        'body': 'línea uno\nlínea dos',
      });

      expect(post.resumen, 'línea uno línea dos');
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

    test('igualdad por valor', () {
      const a = Usuario(id: 1, nombre: 'A', correo: 'a@a.com');
      const b = Usuario(id: 1, nombre: 'A', correo: 'a@a.com');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
