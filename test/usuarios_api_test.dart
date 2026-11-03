import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/services/api_exception.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';

JsonPlaceholderApi _api(MockClient cliente) =>
    JsonPlaceholderApi(client: cliente);

void main() {
  test('usuarios() consulta /users y convierte la lista', () async {
    late Uri uri;
    final api = _api(
      MockClient((solicitud) async {
        uri = solicitud.url;
        return http.Response.bytes(
          utf8.encode('[{"id": 1, "name": "Ana", "email": "ana@example.com"}]'),
          200,
        );
      }),
    );

    final usuarios = await api.usuarios();

    expect(usuarios.single.nombre, 'Ana');
    expect(uri.path, '/users');
    expect(uri.host, 'jsonplaceholder.typicode.com');
    api.dispose();
  });

  test('lanza ApiException cuando el status no es 2xx', () async {
    final api = _api(MockClient((_) async => http.Response('error', 500)));

    await expectLater(
      api.usuarios(),
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

  test('lanza ApiException si el cuerpo no es una lista', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(utf8.encode('{"id": 1}'), 200),
      ),
    );

    await expectLater(
      api.usuarios(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('se esperaba una lista'),
        ),
      ),
    );
    api.dispose();
  });

  test('lanza ApiException si un usuario no cumple el contrato', () async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('[{"id": 1, "name": "Sin correo"}]'),
          200,
        ),
      ),
    );

    await expectLater(api.usuarios(), throwsA(isA<ApiException>()));
    api.dispose();
  });

  test('convierte fallas de conexión en ApiException', () async {
    final api = _api(
      MockClient((_) async => throw http.ClientException('sin red')),
    );

    await expectLater(
      api.usuarios(),
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
}
