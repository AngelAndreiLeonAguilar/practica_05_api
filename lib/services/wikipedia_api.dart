import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/articulo.dart';
import 'api_exception.dart';

/// Cliente de la API pública de Wikipedia en español.
///
/// Usa `action=query&generator=search` para obtener artículos con su
/// introducción ya en texto plano, lo que evita procesar HTML.
class WikipediaApi {
  WikipediaApi({
    http.Client? client,
    this.baseUrl = 'https://es.wikipedia.org/w/api.php',
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _propietarioDelCliente = client == null;

  final http.Client _client;
  final bool _propietarioDelCliente;

  final String baseUrl;
  final Duration timeout;

  /// Busca hasta [limite] artículos relacionados con [consulta].
  Future<List<Articulo>> buscar(String consulta, {int limite = 20}) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'action': 'query',
        'generator': 'search',
        'gsrsearch': consulta,
        'gsrlimit': '$limite',
        'prop': 'extracts',
        'exintro': '1',
        'explaintext': '1',
        'format': 'json',
        'formatversion': '2',
        'origin': '*',
      },
    );

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
        'Error HTTP ${respuesta.statusCode} al consultar la Wikipedia.',
      );
    }

    final Object? json;
    try {
      json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw const ApiException('El cuerpo de la respuesta no es JSON válido.');
    }

    if (json is! Map<String, dynamic>) {
      throw const ApiException(
        'Respuesta inesperada: se esperaba un objeto JSON.',
      );
    }

    final query = json['query'];
    // Sin resultados, la API omite por completo la clave "query".
    if (query == null) return const [];

    if (query is! Map<String, dynamic>) {
      throw const ApiException(
        'Respuesta inesperada: "query" no es un objeto.',
      );
    }

    final paginas = query['pages'];
    if (paginas == null) return const [];
    if (paginas is! List) {
      throw const ApiException(
        'Respuesta inesperada: "pages" no es una lista.',
      );
    }

    final articulos = <Articulo>[];
    for (final pagina in paginas) {
      if (pagina is! Map<String, dynamic>) continue;
      final extracto = pagina['extract'];
      if (extracto is! String || extracto.trim().isEmpty) continue;
      try {
        articulos.add(Articulo.fromJson(pagina));
      } on FormatException {
        continue;
      }
    }
    return articulos;
  }

  /// Libera el cliente HTTP interno (solo si lo creó este objeto).
  void dispose() {
    if (_propietarioDelCliente) {
      _client.close();
    }
  }
}
