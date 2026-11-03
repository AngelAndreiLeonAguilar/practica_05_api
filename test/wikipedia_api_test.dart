import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/services/api_exception.dart';
import 'package:practica_05_api/services/wikipedia_api.dart';

WikipediaApi _api(
  MockClient cliente, {
  Duration timeout = const Duration(seconds: 5),
}) => WikipediaApi(client: cliente, timeout: timeout);

const _jsonDosPaginas = '''
{
  "batchcomplete": true,
  "query": {
    "pages": [
      {"pageid": 1830, "title": "México", "extract": "México es un país de América."},
      {"pageid": 27073, "title": "Estado de México", "extract": "Es una entidad federativa."}
    ]
  }
}
''';

void main() {
  test('buscar() consulta la API con los parámetros esperados', () async {
    late Uri uri;
    final api = _api(
      MockClient((solicitud) async {
        uri = solicitud.url;
        return http.Response.bytes(utf8.encode(_jsonDosPaginas), 200);
      }),
    );

    final articulos = await api.buscar('México', limite: 20);

    expect(articulos, hasLength(2));
    expect(articulos.first.titulo, 'México');
    expect(articulos.last.id, 27073);
    expect(uri.host, 'es.wikipedia.org');
    expect(uri.path, '/w/api.php');
    expect(uri.queryParameters['action'], 'query');
    expect(uri.queryParameters['generator'], 'search');
    expect(uri.queryParameters['gsrsearch'], 'México');
    expect(uri.queryParameters['gsrlimit'], '20');
    expect(uri.queryParameters['formatversion'], '2');
    expect(uri.queryParameters['origin'], '*');
    api.dispose();
  });

  test('omite las páginas que no traen extracto', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('''
          {"query": {"pages": [
            {"pageid": 1, "title": "Con texto", "extract": "Contenido"},
            {"pageid": 2, "title": "Sin texto"},
            {"pageid": 3, "title": "Vacío", "extract": "   "}
          ]}}
          '''),
          200,
        ),
      ),
    );

    final articulos = await api.buscar('prueba');

    expect(articulos, hasLength(1));
    expect(articulos.single.titulo, 'Con texto');
    api.dispose();
  });

  test('una búsqueda sin resultados devuelve lista vacía', () async {
    final api = _api(
      MockClient(
        (_) async =>
            http.Response.bytes(utf8.encode('{"batchcomplete": true}'), 200),
      ),
    );

    expect(await api.buscar('zzzz'), isEmpty);
    api.dispose();
  });

  test('lanza ApiException cuando el status no es 2xx', () async {
    final api = _api(MockClient((_) async => http.Response('error', 503)));

    await expectLater(
      api.buscar('México'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('Error HTTP 503'),
        ),
      ),
    );
    api.dispose();
  });

  test('lanza ApiException si el cuerpo no es JSON', () async {
    final api = _api(
      MockClient((_) async => http.Response.bytes(utf8.encode('<html>'), 200)),
    );

    await expectLater(
      api.buscar('México'),
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

  test('lanza ApiException si "pages" no es una lista', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('{"query": {"pages": {"a": 1}}}'),
          200,
        ),
      ),
    );

    await expectLater(
      api.buscar('México'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('"pages" no es una lista'),
        ),
      ),
    );
    api.dispose();
  });

  test('convierte fallas de conexión en ApiException', () async {
    final api = _api(
      MockClient((_) async => throw http.ClientException('sin red')),
    );

    await expectLater(
      api.buscar('México'),
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
      api.buscar('México'),
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
}
