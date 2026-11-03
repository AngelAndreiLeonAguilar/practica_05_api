// Genera las capturas de evidencia de la práctica a partir de la UI real.
//
// Uso:
//   flutter test tool/capturas/generar_capturas_test.dart --update-goldens
//
// Las imágenes se escriben en docs/evidencias/practica-05/.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practica_05_api/pages/posts_page.dart';
import 'package:practica_05_api/pages/usuarios_page.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';

const _carpetaFuentes = 'C:/Flutter/bin/cache/artifacts/material_fonts';

ByteData _bytes(String ruta) =>
    ByteData.view(File(ruta).readAsBytesSync().buffer);

Future<void> _cargarFuentes() async {
  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(_bytes('$_carpetaFuentes/roboto-regular.ttf')))
    ..addFont(Future.value(_bytes('$_carpetaFuentes/roboto-medium.ttf')))
    ..addFont(Future.value(_bytes('$_carpetaFuentes/roboto-bold.ttf')));
  await roboto.load();

  final iconos = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(_bytes('$_carpetaFuentes/materialicons-regular.otf')),
    );
  await iconos.load();
}

ThemeData _tema() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
  useMaterial3: true,
  fontFamily: 'Roboto',
);

Widget _app(Widget inicio) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: _tema(),
  home: inicio,
);

final _posts = List.generate(20, (i) {
  const titulos = [
    'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
    'qui est esse',
    'ea molestias quasi exercitationem repellat qui ipsa sit aut',
    'eum et est occaecati',
    'nesciunt quas odio',
  ];
  const cuerpos = [
    'quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto',
    'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque fugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis qui aperiam non debitis possimus qui neque nisi nulla',
    'et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel accusantium quis pariatur molestiae porro eius odio et labore et velit aut',
  ];
  return {
    'userId': (i % 10) + 1,
    'id': i + 1,
    'title': titulos[i % titulos.length],
    'body': cuerpos[i % cuerpos.length],
  };
});

String get _jsonPosts => jsonEncode(_posts);

JsonPlaceholderApi _api(MockClient cliente) =>
    JsonPlaceholderApi(client: cliente);

JsonPlaceholderApi _apiConDatos() => _api(
  MockClient((_) async => http.Response.bytes(utf8.encode(_jsonPosts), 200)),
);

const _rutaEvidencias = '../../docs/evidencias/practica-05/';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _cargarFuentes();
  });

  Future<void> configurarVista(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> capturar(WidgetTester tester, String archivo) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('$_rutaEvidencias$archivo'),
  );

  testWidgets('01 lista de publicaciones', (tester) async {
    await configurarVista(tester);
    await tester.pumpWidget(_app(PostsPage(api: _apiConDatos())));
    await tester.pumpAndSettle();
    await capturar(tester, '01-lista.png');
  });

  testWidgets('02 detalle de publicacion', (tester) async {
    await configurarVista(tester);
    await tester.pumpWidget(_app(PostsPage(api: _apiConDatos())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-1')));
    await tester.pumpAndSettle();
    await capturar(tester, '02-detalle.png');
  });

  testWidgets('03 estado de carga', (tester) async {
    await configurarVista(tester);
    final pendiente = Completer<http.Response>();
    await tester.pumpWidget(
      _app(PostsPage(api: _api(MockClient((_) => pendiente.future)))),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await capturar(tester, '03-carga.png');

    // Cierra la petición para no dejar temporizadores pendientes.
    pendiente.complete(http.Response.bytes(utf8.encode(_jsonPosts), 200));
    await tester.pumpAndSettle();
  });

  testWidgets('04 estado de error', (tester) async {
    await configurarVista(tester);
    final api = _api(MockClient((_) async => http.Response('boom', 500)));
    await tester.pumpWidget(_app(PostsPage(api: api)));
    await tester.pumpAndSettle();
    await capturar(tester, '04-error.png');
  });

  testWidgets('05 estado vacio', (tester) async {
    await configurarVista(tester);
    final api = _api(
      MockClient((_) async => http.Response.bytes(utf8.encode('[]'), 200)),
    );
    await tester.pumpWidget(_app(PostsPage(api: api)));
    await tester.pumpAndSettle();
    await capturar(tester, '05-vacio.png');
  });

  testWidgets('06 ejemplo guiado con usuarios', (tester) async {
    await configurarVista(tester);
    final api = _api(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {'id': 1, 'name': 'Leanne Graham', 'email': 'Sincere@april.biz'},
              {'id': 2, 'name': 'Ervin Howell', 'email': 'Shanna@melissa.tv'},
              {
                'id': 3,
                'name': 'Clementine Bauch',
                'email': 'Nathan@yesenia.net',
              },
              {
                'id': 4,
                'name': 'Patricia Lebsack',
                'email': 'Julianne.OConner@kory.org',
              },
              {
                'id': 5,
                'name': 'Chelsey Dietrich',
                'email': 'Lucio_Hettinger@annie.ca',
              },
            ]),
          ),
          200,
        ),
      ),
    );
    await tester.pumpWidget(_app(UsuariosPage(api: api)));
    await tester.pumpAndSettle();
    await capturar(tester, '06-usuarios.png');
  });
}
