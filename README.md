# Práctica 05 · Consumo de API REST y procesamiento JSON

Aplicación Flutter que consume el API público [JSONPlaceholder](https://jsonplaceholder.typicode.com),
convierte las respuestas JSON a objetos de dominio y representa los estados de **carga**,
**éxito**, **error** y **lista vacía**. Incluye el ejemplo guiado (`/users`) y el ejercicio
evaluable (`/posts`).

## Objetivo

Consumir un servicio REST mediante HTTP, convertir JSON a objetos Dart y representar estados
de carga, éxito y error, aplicando el mismo patrón a la fuente de datos del proyecto integrador.

## Requisitos

| Herramienta | Versión utilizada |
| --- | --- |
| Flutter | 3.47.2 (stable) |
| Dart | 3.13.2 |
| Paquete `http` | 1.6.0 |
| Git | 2.x |
| Conexión a Internet | Requerida para consultar el API |

## Instalación

```bash
git clone <URL-del-repositorio>
cd practica_05_api
flutter pub get
```

## Ejecución

```bash
# Dispositivo o emulador conectado
flutter run

# Destinos disponibles
flutter devices

# Versión web
flutter run -d chrome
```

> En Android, el permiso `android.permission.INTERNET` ya está declarado en
> `android/app/src/main/AndroidManifest.xml`.

## Uso de la aplicación

La pantalla principal tiene dos secciones en la barra de navegación inferior:

1. **Publicaciones** (ejercicio evaluable): lista de `/posts` con indicador de carga,
   mensaje de error con botón *Reintentar*, estado vacío, actualización con
   *arrastrar para actualizar* (`RefreshIndicator`) y pantalla de detalle al tocar una
   publicación.
2. **Usuarios** (ejemplo guiado): lista de `/users` con los mismos estados.

## API utilizada

| Método | Endpoint | Respuesta | Uso |
| --- | --- | --- | --- |
| GET | `/posts` | `[{ userId, id, title, body }]` | Lista del ejercicio evaluable |
| GET | `/posts/{id}` | `{ userId, id, title, body }` | Disponible en el servicio para consultar una publicación |
| GET | `/users` | `[{ id, name, email }]` | Ejemplo guiado |

Contrato JSON de una publicación:

```json
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit suscipit recusandae consequuntur expedita et cum..."
}
```

## Estructura del proyecto

```text
lib/
├── main.dart                        # Punto de entrada
├── app.dart                         # MaterialApp y tema
├── models/
│   ├── json_utils.dart              # Lectura segura de campos JSON
│   ├── post.dart                    # Modelo Post + fromJson
│   └── usuario.dart                 # Modelo Usuario + fromJson
├── pages/
│   ├── home_shell.dart              # Navegación entre las dos pantallas
│   ├── posts_page.dart              # Ejercicio evaluable (/posts)
│   ├── post_detail_page.dart        # Detalle de una publicación
│   └── usuarios_page.dart           # Ejemplo guiado (/users)
├── services/
│   └── json_placeholder_api.dart    # Cliente HTTP, timeout y validación
└── widgets/
    └── estados.dart                 # Vistas de carga, error y vacío
test/
├── models_test.dart                 # Conversión JSON → objetos Dart
├── json_placeholder_api_test.dart   # HTTP, status, errores y timeout
└── posts_page_test.dart             # Widgets: estados, refresco y detalle
tool/capturas/generar_capturas_test.dart  # Genera las capturas de evidencia
docs/evidencias/practica-05/         # Capturas de la aplicación
```

## Flujo de una petición

1. `PostsPage.initState` llama a `JsonPlaceholderApi.posts()`; el `Future` se guarda en el estado.
2. `http.get` agrega la cabecera `Accept: application/json` y aplica un timeout de 10 s.
3. Se valida el código de estado: fuera del rango `200–299` se lanza `ApiException`.
4. `jsonDecode` convierte el cuerpo (UTF-8) y cada elemento pasa por `Post.fromJson`.
5. `FutureBuilder` representa `waiting` (carga), `hasError` (error), lista vacía o lista de tarjetas.
6. `RefreshIndicator` vuelve a ejecutar la petición; el detalle navega con `Navigator.push`.

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

Resultados obtenidos en este repositorio:

- `flutter analyze`: **No issues found!**
- `flutter test`: **24 pruebas, todas aprobadas** (`+24: All tests passed!`)

Cobertura de las pruebas:

| Archivo | Qué valida |
| --- | --- |
| `models_test.dart` | Conversión de JSON, números como texto, campos faltantes o con tipo incorrecto |
| `json_placeholder_api_test.dart` | URL y cabecera `Accept`, status 2xx, HTTP 500, JSON inválido, respuesta que no es lista, error de conexión, timeout y lista vacía |
| `posts_page_test.dart` | Indicador de carga, lista, error con reintento, estado vacío, `RefreshIndicator`, navegación al detalle y ejemplo guiado |

### Capturas de evidencia

Las imágenes de `docs/evidencias/practica-05/` se generan desde la UI real con:

```bash
flutter test tool/capturas/generar_capturas_test.dart --update-goldens
```

| Archivo | Estado mostrado |
| --- | --- |
| `01-lista.png` | Lista de publicaciones con datos |
| `02-detalle.png` | Pantalla de detalle |
| `03-carga.png` | Indicador de carga |
| `04-error.png` | Error HTTP con botón *Reintentar* |
| `05-vacio.png` | Lista vacía |
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
- Flutter. *JSON and serialization*. https://docs.flutter.dev/data-and-backend/serialization/json
- JSONPlaceholder. https://jsonplaceholder.typicode.com
