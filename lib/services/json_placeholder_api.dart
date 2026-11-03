import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import 'api_exception.dart';

/// Cliente del API público JSONPlaceholder (ejemplo guiado de `/users`).
class JsonPlaceholderApi {
  JsonPlaceholderApi({
    http.Client? client,
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _propietarioDelCliente = client == null;

  final http.Client _client;
  final bool _propietarioDelCliente;

  final String baseUrl;
  final Duration timeout;

  /// GET `/users`.
  Future<List<Usuario>> usuarios() async {
    final uri = Uri.parse('$baseUrl/users');
    final http.Response respuesta;
    try {
      respuesta = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'La solicitud excedió el tiempo de espera. Revisa tu conexión.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el servidor. Revisa tu conexión a Internet.',
      );
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw ApiException(
        'Error HTTP ${respuesta.statusCode} al consultar /users.',
      );
    }

    final Object? json;
    try {
      json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw const ApiException('El cuerpo de la respuesta no es JSON válido.');
    }

    if (json is! List) {
      throw const ApiException(
        'Respuesta inesperada: se esperaba una lista JSON.',
      );
    }

    try {
      return json
          .map((elemento) => Usuario.fromJson(elemento as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException catch (e) {
      throw ApiException('Datos inválidos en /users: ${e.message}');
    } on TypeError {
      throw const ApiException(
        'Datos inválidos en /users: se esperaban objetos JSON.',
      );
    }
  }

  /// Libera el cliente HTTP interno (solo si lo creó este objeto).
  void dispose() {
    if (_propietarioDelCliente) {
      _client.close();
    }
  }
}
