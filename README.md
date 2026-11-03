# Práctica 05 · Consumo de API REST y procesamiento JSON

Aplicación Flutter que consume servicios REST públicos, convierte las respuestas JSON a
objetos de dominio y representa los estados de **carga**, **éxito**, **error** y **lista
vacía**.

- **Artículos**: contenido real en español desde la API de **Wikipedia en español**
  (`action=query&generator=search`), con buscador, estados, actualización y detalle.
- **Usuarios**: ejemplo guiado de la práctica contra `/users` de **JSONPlaceholder**.

## Objetivo

Consumir un servicio REST mediante HTTP, convertir JSON a objetos Dart y representar estados
de carga, éxito y error, aplicando el mismo patrón a la fuente de datos del proyecto integrador.

## Requisitos

| Herramienta | Versión utilizada |
| --- | --- |
| Flutter | 3.47.2 (stable) |
| Dart | 3.13.2 |
| Paquete `http` | 1.6.0 |
| `flutter_localizations` | SDK (interfaz en es-MX) |
| Conexión a Internet | Requerida para consultar las APIs |

## Instalación

```bash
git clone <URL-del-repositorio>
cd practica_05_api
flutter pub get
```

## Ejecución

```bash
flutter run                 # dispositivo o emulador conectado
flutter devices             # destinos disponibles
flutter run -d chrome       # web
flutter run -d windows      # escritorio
```

> En Android el permiso `android.permission.INTERNET` ya está declarado en
> `android/app/src/main/AndroidManifest.xml`. Ambos servicios permiten CORS, por lo que
> funcionan también en web.

## Uso de la aplicación

La barra inferior tiene dos secciones:

1. **Artículos** (pantalla principal): busca en la Wikipedia en español (tema inicial
   «México»), muestra 20 resultados con título y resumen, indicador de carga, error con
   *Reintentar*, estado vacío, actualización con *arrastrar para actualizar*
   (`RefreshIndicator`) y pantalla de detalle al tocar un artículo.
2. **Usuarios** (ejemplo guiado): lista de `/users` de JSONPlaceholder con los mismos estados.

## APIs utilizadas

### Wikipedia en español

`GET https://es.wikipedia.org/w/api.php`

| Parámetro | Valor | Propósito |
| --- | --- | --- |
| `action` | `query` | Consulta a la API |
| `generator` | `search` | Genera resultados a partir de una búsqueda |
| `gsrsearch` | tema | Texto buscado |
| `gsrlimit` | `20` | Número de resultados |
| `prop` | `extracts` | Texto del artículo |
| `exintro` / `explaintext` | `1` | Solo introducción, sin HTML |
| `format` / `formatversion` | `json` / `2` | JSON con páginas como arreglo |
| `origin` | `*` | Habilita CORS para la versión web |

Respuesta (resumida):

```json
{
  "query": {
    "pages": [
      { "pageid": 1830, "title": "México", "extract": "México, oficialmente Estados Unidos Mexicanos…" }
    ]
  }
}
```

Si no hay resultados, la API omite la clave `query`; el cliente la interpreta como lista vacía.

### JSONPlaceholder (ejemplo guiado)

| Método | Endpoint | Respuesta |
| --- | --- | --- |
| GET | `/users` | `[{ id, name, email }]` |

## Estructura del proyecto

```text
lib/
├── main.dart                        # Punto de entrada
├── app.dart                         # MaterialApp, tema y localización es-MX
├── models/
│   ├── json_utils.dart              # Lectura segura de campos JSON
│   ├── articulo.dart                # Modelo Articulo + fromJson
│   └── usuario.dart                 # Modelo Usuario + fromJson
├── pages/
│   ├── home_shell.dart              # Navegación entre las dos pantallas
│   ├── articulos_page.dart          # Wikipedia: lista, buscador y estados
│   ├── articulo_detalle_page.dart   # Detalle del artículo
│   └── usuarios_page.dart           # Ejemplo guiado (/users)
├── services/
│   ├── api_exception.dart           # Error de dominio compartido
│   ├── wikipedia_api.dart           # Cliente de la API de Wikipedia
│   └── json_placeholder_api.dart    # Cliente de /users
└── widgets/
    └── estados.dart                 # Vistas de carga, error y vacío
test/
├── modelos_test.dart                # JSON → objetos Dart
├── wikipedia_api_test.dart          # Parámetros, parseo y errores HTTP
├── usuarios_api_test.dart           # Ejemplo guiado
└── articulos_page_test.dart         # Estados, búsqueda, refresco y detalle
tool/capturas/evidencias_test.dart   # Genera las capturas de evidencia
docs/evidencias/practica-05/         # Capturas de la aplicación
```

## Flujo de una petición

1. `ArticulosPage.initState` llama a `WikipediaApi.buscar('México')` y guarda el `Future`.
2. Se construye la URL con parámetros de consulta (búsqueda, límite, formato y CORS) y se
   envía con la cabecera `Accept: application/json` y un timeout de 10 s.
3. Se valida el status: fuera de `200–299` se lanza `ApiException`.
4. `jsonDecode` convierte el cuerpo UTF-8; se recorre `query.pages` y cada página pasa por
   `Articulo.fromJson` (se descartan las que no traen extracto).
5. `FutureBuilder` representa `waiting` (carga), `hasError` (error), lista vacía o tarjetas.
6. `RefreshIndicator` repite la petición; el buscador cambia el término; el detalle navega
   con `Navigator.push`.

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

Resultados en este repositorio:

- `flutter analyze`: **No issues found!**
- `flutter test`: **28 pruebas, todas aprobadas** (`+28: All tests passed!`)

| Archivo | Qué valida |
| --- | --- |
| `modelos_test.dart` | Conversión de JSON, campos faltantes o con tipo incorrecto, resumen recortado |
| `wikipedia_api_test.dart` | Parámetros enviados, parseo de páginas, omisión de extractos vacíos, sin resultados, HTTP 503, JSON inválido, `pages` mal formado, error de conexión y timeout |
| `usuarios_api_test.dart` | `/users`: contrato, HTTP 500, respuesta que no es lista, campos faltantes y error de conexión |
| `articulos_page_test.dart` | Carga, lista, error con reintento, vacío, `RefreshIndicator`, buscador, navegación al detalle y ejemplo guiado |

### Capturas de evidencia

Se generan desde la UI real con:

```bash
flutter test tool/capturas/evidencias_test.dart --update-goldens
```

| Archivo | Estado mostrado |
| --- | --- |
| `01-lista.png` | Lista de artículos con datos |
| `02-detalle.png` | Pantalla de detalle |
| `03-carga.png` | Indicador de carga |
| `04-error.png` | Error HTTP con botón *Reintentar* |
| `05-vacio.png` | Sin resultados |
| `06-usuarios.png` | Ejemplo guiado `/users` |

## Flujo de trabajo en Git

```bash
git checkout develop
git pull origin develop
git checkout -b practica-05-api-rest

# desarrollo y verificación
dart format .
flutter analyze
flutter test

git add .
git commit -m "feat: completa practica 05"
git push -u origin practica-05-api-rest
```

Después del `push` se crea una *pull request* hacia `develop` con propósito, funciones
agregadas, pasos para ejecutar, pruebas realizadas, capturas y pendientes.

Ramas locales de este repositorio:

- `develop`: proyecto base.
- `practica-05-api-rest`: desarrollo de la práctica.

## Participantes

| Nombre | Rol |
| --- | --- |
| _(integrante 1)_ | Desarrollo Flutter |
| _(integrante 2)_ | Pruebas y evidencias |

## Referencias

- Flutter. *Fetch data from the internet*. https://docs.flutter.dev/cookbook/networking/fetch-data
- Dart. *JSON support*. https://dart.dev/libraries/dart-convert
- Dart. *Asynchronous programming*. https://dart.dev/language/async
- Flutter. *Internationalization*. https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Wikimedia. *MediaWiki API*. https://www.mediawiki.org/wiki/API:Main_page
- JSONPlaceholder. https://jsonplaceholder.typicode.com
