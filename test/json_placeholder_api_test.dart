import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';

JsonPlaceholderApi _api(
  MockClient cliente, {
  Duration timeout = const Duration(seconds: 5),
}) => JsonPlaceholderApi(client: cliente, timeout: timeout);

void main() {
  const jsonPosts = '''
  [
    {"userId": 1, "id": 1, "title": "uno", "body": "cuerpo uno"},
    {"userId": 2, "id": 2, "title": "dos", "body": "cuerpo dos"}
  ]
  ''';

  test('posts() consulta /posts y convierte la lista a objetos Dart', () async {
    late Uri uriSolicitada;
    late String? accept;
    final api = _api(
      MockClient((solicitud) async {
        uriSolicitada = solicitud.url;
        accept = solicitud.headers['Accept'];
        return http.Response.bytes(utf8.encode(jsonPosts), 200);
      }),
    );

    final posts = await api.posts();

    expect(posts, hasLength(2));
    expect(posts.first.titulo, 'uno');
    expect(posts.last.id, 2);
    expect(uriSolicitada.path, '/posts');
    expect(uriSolicitada.host, 'jsonplaceholder.typicode.com');
    expect(accept, 'application/json');
    api.dispose();
  });

  test('usuarios() consulta /users', () async {
    final api = _api(
      MockClient((solicitud) async {
        expect(solicitud.url.path, '/users');
        return http.Response.bytes(
          utf8.encode(
            '[{"id": 1, "name": "Ana", "email": "ana@example.com"}]',
          ),
          200,
        );
      }),
    );

    final usuarios = await api.usuarios();

    expect(usuarios.single.nombre, 'Ana');
    api.dispose();
  });

  test('post(id) consulta /posts/{id}', () async {
    final api = _api(
      MockClient((solicitud) async {
        expect(solicitud.url.path, '/posts/5');
        return http.Response.bytes(
          utf8.encode('{"userId":1,"id":5,"title":"t","body":"b"}'),
          200,
        );
      }),
    );

    final post = await api.post(5);

    expect(post.id, 5);
    api.dispose();
  });

  test('lanza ApiException cuando el status no es 2xx', () async {
    final api = _api(
      MockClient((_) async => http.Response('error interno', 500)),
    );

    await expectLater(
      api.posts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('Error HTTP 500'),
        ),
      ),
    );
    api.dispose();
  });

  test('lanza ApiException si el cuerpo no es JSON', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(utf8.encode('<html></html>'), 200),
      ),
    );

    await expectLater(
      api.posts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('no es JSON válido'),
        ),
      ),
    );
    api.dispose();
  });

  test('lanza ApiException si el JSON no es una lista', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(utf8.encode('{"id": 1}'), 200),
      ),
    );

    await expectLater(
      api.posts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('lista JSON'),
        ),
      ),
    );
    api.dispose();
  });

  test('lanza ApiException si un elemento no cumple el contrato', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('[{"userId": 1, "id": 1, "title": "sin cuerpo"}]'),
          200,
        ),
      ),
    );

    await expectLater(
      api.posts(),
      throwsA(isA<ApiException>()),
    );
    api.dispose();
  });

  test('convierte fallas de conexión en ApiException', () async {
    final api = _api(
      MockClient(
        (_) async => throw http.ClientException('sin red'),
      ),
    );

    await expectLater(
      api.posts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('No fue posible conectar'),
        ),
      ),
    );
    api.dispose();
  });

  test('respeta el tiempo de espera configurado', () async {
    final api = _api(
      MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 50),
    );

    await expectLater(
      api.posts(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('tiempo de espera'),
        ),
      ),
    );
    api.dispose();
  });

  test('una lista vacía devuelve una colección vacía', () async {
    final api = _api(
      MockClient((_) async => http.Response.bytes(utf8.encode('[]'), 200)),
    );

    expect(await api.posts(), isEmpty);
    api.dispose();
  });
}
