import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/pages/posts_page.dart';
import 'package:practica_05_api/pages/usuarios_page.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';

const _jsonPosts = '''
[
  {"userId": 1, "id": 1, "title": "Título uno", "body": "Cuerpo uno"},
  {"userId": 2, "id": 2, "title": "Título dos", "body": "Cuerpo dos"}
]
''';

Widget _envolver(Widget hijo) => MaterialApp(home: hijo);

JsonPlaceholderApi _api(MockClient cliente) =>
    JsonPlaceholderApi(client: cliente);

void main() {
  testWidgets('muestra el indicador de carga y luego la lista', (tester) async {
    final completer = Completer<http.Response>();
    final api = _api(MockClient((_) => completer.future));

    await tester.pumpWidget(_envolver(PostsPage(api: api)));

    expect(find.byKey(const Key('estado-carga')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(http.Response.bytes(utf8.encode(_jsonPosts), 200));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-carga')), findsNothing);
    expect(find.byKey(const Key('lista-posts')), findsOneWidget);
    expect(find.text('Título uno'), findsOneWidget);
    expect(find.text('Título dos'), findsOneWidget);
    expect(find.text('Usuario 1'), findsOneWidget);
  });

  testWidgets('muestra el estado de error con mensaje HTTP', (tester) async {
    final api = _api(MockClient((_) async => http.Response('falla', 404)));

    await tester.pumpWidget(_envolver(PostsPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-error')), findsOneWidget);
    expect(find.textContaining('Error HTTP 404'), findsOneWidget);
  });

  testWidgets('reintenta la petición desde el botón del error', (tester) async {
    var llamadas = 0;
    final api = _api(
      MockClient((_) async {
        llamadas++;
        if (llamadas == 1) {
          return http.Response('falla', 503);
        }
        return http.Response.bytes(utf8.encode(_jsonPosts), 200);
      }),
    );

    await tester.pumpWidget(_envolver(PostsPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('estado-error')), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton-reintentar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-error')), findsNothing);
    expect(find.text('Título uno'), findsOneWidget);
    expect(llamadas, 2);
  });

  testWidgets('muestra el estado vacío cuando el API no devuelve datos', (
    tester,
  ) async {
    final api = _api(
      MockClient((_) async => http.Response.bytes(utf8.encode('[]'), 200)),
    );

    await tester.pumpWidget(_envolver(PostsPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('estado-vacio')), findsOneWidget);
  });

  testWidgets('RefreshIndicator vuelve a consultar el API', (tester) async {
    var llamadas = 0;
    final api = _api(
      MockClient((_) async {
        llamadas++;
        return http.Response.bytes(utf8.encode(_jsonPosts), 200);
      }),
    );

    await tester.pumpWidget(_envolver(PostsPage(api: api)));
    await tester.pumpAndSettle();
    expect(llamadas, 1);

    await tester.fling(
      find.byKey(const Key('lista-posts')),
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    expect(llamadas, 2);
  });

  testWidgets('al tocar una publicación se abre el detalle', (tester) async {
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(utf8.encode(_jsonPosts), 200),
      ),
    );

    await tester.pumpWidget(_envolver(PostsPage(api: api)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('post-2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detalle-titulo')), findsOneWidget);
    expect(find.text('Título dos'), findsOneWidget);
    expect(find.text('Cuerpo dos'), findsOneWidget);
    expect(find.text('Publicación 2'), findsOneWidget);
  });

  testWidgets('el ejemplo guiado lista usuarios', (tester) async {
    final api = _api(
      MockClient(
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
