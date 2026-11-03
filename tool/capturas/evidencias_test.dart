// Genera las capturas de evidencia de la práctica a partir de la UI real.
//
// Uso:
//   flutter test tool/capturas/evidencias_test.dart --update-goldens
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
import 'package:practica_05_api/pages/articulos_page.dart';
import 'package:practica_05_api/pages/usuarios_page.dart';
import 'package:practica_05_api/services/json_placeholder_api.dart';
import 'package:practica_05_api/services/wikipedia_api.dart';

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

const _temas = <String, String>{
  'México': 'México, oficialmente Estados Unidos Mexicanos, es un país soberano ubicado en la parte meridional de América del Norte; su capital y ciudad más poblada es la Ciudad de México.',
  'Estado de México': 'Estado de México, oficialmente denominado Estado Libre y Soberano de México, es uno de los treinta y un estados que conforman México. Su capital es Toluca de Lerdo.',
  'Ciudad de México': 'La Ciudad de México es la capital de los Estados Unidos Mexicanos, sede de los Poderes de la Unión y una de las entidades federativas de la nación.',
  'Guadalajara': 'Guadalajara es una ciudad mexicana, capital del estado de Jalisco. Es la segunda ciudad más poblada del país y el centro de la Zona Metropolitana de Guadalajara.',
  'Monterrey': 'Monterrey es la capital del estado de Nuevo León y la ciudad más poblada de la región noreste de México. Es un importante centro industrial y financiero.',
  'Oaxaca': 'Oaxaca es uno de los treinta y un estados de México. Su capital es la ciudad de Oaxaca de Juárez, declarada Patrimonio Cultural de la Humanidad.',
  'Puebla': 'Puebla es un estado del centro de México. Su capital, Heroica Puebla de Zaragoza, destaca por su arquitectura colonial y su gastronomía.',
  'Yucatán': 'Yucatán es un estado de la península homónima. Su capital es Mérida y es conocido por sus cenotes y sitios arqueológicos mayas.',
  'Quintana Roo': 'Quintana Roo es un estado del sureste mexicano, en la península de Yucatán. Su capital es Chetumal y Cancún es su ciudad más conocida.',
  'Guanajuato': 'Guanajuato es un estado del centro de México. Su capital homónima es Patrimonio de la Humanidad y sede del Festival Internacional Cervantino.',
  'Chiapas': 'Chiapas es el estado más meridional de México. Su capital es Tuxtla Gutiérrez y alberga la Selva Lacandona y las ruinas de Palenque.',
  'Veracruz': 'Veracruz es un estado del golfo de México. Su capital es Xalapa y el puerto de Veracruz es uno de los más antiguos del continente.',
  'Jalisco': 'Jalisco es un estado del occidente de México. Su capital es Guadalajara y es la cuna del mariachi y del tequila.',
  'Michoacán': 'Michoacán es un estado del occidente mexicano. Su capital es Morelia y es famoso por la mariposa monarca y su cocina tradicional.',
  'Chihuahua': 'Chihuahua es el estado más grande de México. Su capital es la ciudad homónima y comparte con Estados Unidos una extensa frontera.',
  'Sonora': 'Sonora es un estado del noroeste de México, fronterizo con Arizona. Su capital es Hermosillo y cuenta con el desierto de Altar.',
  'Sinaloa': 'Sinaloa es un estado del noroeste de México. Su capital es Culiacán y su litoral se extiende por el golfo de California.',
  'Tamaulipas': 'Tamaulipas es un estado del noreste de México, fronterizo con Texas. Su capital es Ciudad Victoria.',
  'Coahuila': 'Coahuila de Zaragoza es un estado del norte de México. Su capital es Saltillo y comparte con Texas una frontera de más de 500 km.',
  'Nuevo León': 'Nuevo León es un estado del noreste de México. Su capital es Monterrey, principal centro industrial del país.',
};

List<Map<String, dynamic>> _paginas() {
  var id = 1830;
  return _temas.entries
      .map((e) => {'pageid': id++, 'ns': 0, 'title': e.key, 'extract': e.value})
      .toList();
}

String get _jsonArticulos => jsonEncode({
  'query': {'pages': _paginas()},
});

WikipediaApi _wiki(MockClient cliente) => WikipediaApi(client: cliente);

WikipediaApi _apiConDatos() => _wiki(
  MockClient(
    (_) async => http.Response.bytes(utf8.encode(_jsonArticulos), 200),
  ),
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

  testWidgets('01 lista de articulos', (tester) async {
    await configurarVista(tester);
    await tester.pumpWidget(_app(ArticulosPage(api: _apiConDatos())));
    await tester.pumpAndSettle();
    await capturar(tester, '01-lista.png');
  });

  testWidgets('02 detalle de articulo', (tester) async {
    await configurarVista(tester);
    await tester.pumpWidget(_app(ArticulosPage(api: _apiConDatos())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('articulo-1830')));
    await tester.pumpAndSettle();
    await capturar(tester, '02-detalle.png');
  });

  testWidgets('03 estado de carga', (tester) async {
    await configurarVista(tester);
    final pendiente = Completer<http.Response>();
    await tester.pumpWidget(
      _app(ArticulosPage(api: _wiki(MockClient((_) => pendiente.future)))),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await capturar(tester, '03-carga.png');

    // Cierra la petición para no dejar temporizadores pendientes.
    pendiente.complete(http.Response.bytes(utf8.encode(_jsonArticulos), 200));
    await tester.pumpAndSettle();
  });

  testWidgets('04 estado de error', (tester) async {
    await configurarVista(tester);
    final api = _wiki(MockClient((_) async => http.Response('boom', 500)));
    await tester.pumpWidget(_app(ArticulosPage(api: api)));
    await tester.pumpAndSettle();
    await capturar(tester, '04-error.png');
  });

  testWidgets('05 estado vacio', (tester) async {
    await configurarVista(tester);
    final api = _wiki(
      MockClient(
        (_) async =>
            http.Response.bytes(utf8.encode('{"batchcomplete": true}'), 200),
      ),
    );
    await tester.pumpWidget(_app(ArticulosPage(api: api)));
    await tester.pumpAndSettle();
    await capturar(tester, '05-vacio.png');
  });

  testWidgets('06 ejemplo guiado con usuarios', (tester) async {
    await configurarVista(tester);
    final api = JsonPlaceholderApi(
      client: MockClient(
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
