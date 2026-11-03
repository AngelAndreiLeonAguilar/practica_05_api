import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/usuario.dart';

/// Error de dominio para fallas de red, HTTP o de formato JSON.
class ApiException implements Exception {
  const ApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Cliente del API público JSONPlaceholder.
///
/// Centraliza la URL base, el tiempo de espera, la validación del código de
/// estado y la conversión de JSON a objetos de dominio.
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
  Future<List<Usuario>> usuarios() => _obtenerLista('/users', Usuario.fromJson);

  /// GET `/posts`.
  Future<List<Post>> posts() => _obtenerLista('/posts', Post.fromJson);

  /// GET `/posts/{id}`.
  Future<Post> post(int id) async {
    final json = await _obtenerJson('/posts/$id');
    if (json is! Map<String, dynamic>) {
      throw const ApiException(
        'Respuesta inesperada: se esperaba un objeto JSON.',
      );
    }
    try {
      return Post.fromJson(json);
    } on FormatException catch (e) {
      throw ApiException('Datos de publicación inválidos: ${e.message}');
    }
  }

  Future<List<T>> _obtenerLista<T>(
    String ruta,
    T Function(Map<String, dynamic>) desdeJson,
  ) async {
    final json = await _obtenerJson(ruta);
    if (json is! List) {
      throw const ApiException(
        'Respuesta inesperada: se esperaba una lista JSON.',
      );
    }
    try {
      return json
          .map((elemento) => desdeJson(elemento as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException catch (e) {
      throw ApiException('Datos inválidos en $ruta: ${e.message}');
    } on TypeError {
      throw ApiException(
        'Datos inválidos en $ruta: se esperaban objetos JSON.',
      );
    }
  }

  Future<Object?> _obtenerJson(String ruta) async {
    final uri = Uri.parse('$baseUrl$ruta');
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
        'Error HTTP ${respuesta.statusCode} al consultar $ruta.',
      );
    }

    try {
      return jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw const ApiException('El cuerpo de la respuesta no es JSON válido.');
    }
  }

  /// Libera el cliente HTTP interno (solo si lo creó este objeto).
  void dispose() {
    if (_propietarioDelCliente) {
      _client.close();
    }
  }
}
