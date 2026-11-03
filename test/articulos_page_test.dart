import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/pages/articulos_page.dart';
import 'package:practica_05_api/pages/usuarios_page.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';
import 'package:practica_05_api/services/wikipedia_api.dart';

const _jsonArticulos = '''
{
  "query": {
    "pages": [
      {"pageid": 1830, "title": "México", "extract": "México es un país de América del Norte."},
      {"pageid": 27073, "title": "Estado de México", "extract": "Es una entidad federativa del centro del país."}
    ]
  }
}
''';

Widget _envolver(Widget hijo) => MaterialApp(home: hijo);

WikipediaApi _wiki(MockClient cliente) => WikipediaApi(client: cliente);

void main() {
  testWidgets('muestra el indicador de carga y luego los artículos', (
    tester,
  ) async {
    final completer = Completer<http.Response>();
    final api = _wiki(MockClient((_) => completer.future));

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));

    expect(find.byKey(const Key('estado-carga')), findsOneWidget);
    expect(find.textContaining('Buscando'), findsOneWidget);

    completer.complete(http.Response.bytes(utf8.encode(_jsonArticulos), 200));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-carga')), findsNothing);
    expect(find.byKey(const Key('lista-articulos')), findsOneWidget);
    expect(find.byKey(const Key('articulo-1830')), findsOneWidget);
    expect(find.text('Estado de México'), findsOneWidget);
  });

  testWidgets('muestra el estado de error con mensaje HTTP', (tester) async {
    final api = _wiki(MockClient((_) async => http.Response('falla', 404)));

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-error')), findsOneWidget);
    expect(find.textContaining('Error HTTP 404'), findsOneWidget);
  });

  testWidgets('reintenta la petición desde el botón del error', (tester) async {
    var llamadas = 0;
    final api = _wiki(
      MockClient((_) async {
        llamadas++;
        if (llamadas == 1) return http.Response('falla', 503);
        return http.Response.bytes(utf8.encode(_jsonArticulos), 200);
      }),
    );

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('estado-error')), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton-reintentar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-error')), findsNothing);
    expect(find.byKey(const Key('articulo-1830')), findsOneWidget);
    expect(llamadas, 2);
  });

  testWidgets('muestra el estado vacío cuando no hay resultados', (
    tester,
  ) async {
    final api = _wiki(
      MockClient(
        (_) async =>
            http.Response.bytes(utf8.encode('{"batchcomplete": true}'), 200),
      ),
    );

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-vacio')), findsOneWidget);
    expect(find.textContaining('No se encontraron artículos'), findsOneWidget);
  });

  testWidgets('RefreshIndicator vuelve a consultar la API', (tester) async {
    var llamadas = 0;
    final api = _wiki(
      MockClient((_) async {
        llamadas++;
        return http.Response.bytes(utf8.encode(_jsonArticulos), 200);
      }),
    );

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();
    expect(llamadas, 1);

    await tester.fling(
      find.byKey(const Key('lista-articulos')),
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    expect(llamadas, 2);
  });

  testWidgets('el buscador consulta la API con el nuevo término', (
    tester,
  ) async {
    final consultas = <String>[];
    final api = _wiki(
      MockClient((solicitud) async {
        consultas.add(solicitud.url.queryParameters['gsrsearch'] ?? '');
        return http.Response.bytes(utf8.encode(_jsonArticulos), 200);
      }),
    );

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();
    expect(consultas, ['México']);

    await tester.enterText(find.byKey(const Key('campo-busqueda')), 'Oaxaca');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(consultas, ['México', 'Oaxaca']);
    expect(find.text('México'), findsOneWidget);
  });

  testWidgets('al tocar un artículo se abre el detalle', (tester) async {
    final api = _wiki(
      MockClient(
        (_) async => http.Response.bytes(utf8.encode(_jsonArticulos), 200),
      ),
    );

    await tester.pumpWidget(_envolver(ArticulosPage(api: api)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('articulo-27073')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detalle-titulo')), findsOneWidget);
    expect(find.text('Estado de México'), findsOneWidget);
    expect(find.textContaining('entidad federativa'), findsOneWidget);
    expect(find.text('Artículo 27073'), findsOneWidget);
  });

  testWidgets('el ejemplo guiado lista usuarios', (tester) async {
    final api = JsonPlaceholderApi(
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('[{"id": 1, "name": "Ana", "email": "ana@a.com"}]'),
          200,
        ),
      ),
    );

    await tester.pumpWidget(_envolver(UsuariosPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('ana@a.com'), findsOneWidget);
    expect(find.byKey(const Key('lista-usuarios')), findsOneWidget);
  });
}
