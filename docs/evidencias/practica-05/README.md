# Evidencias · Práctica 05

Capturas generadas desde la interfaz real de la aplicación con
`flutter test tool/capturas/generar_capturas_test.dart --update-goldens`
(las imágenes se producen con el mismo árbol de widgets que se ejecuta en la app).

| Archivo | Pantalla | Estado |
| --- | --- | --- |
| `01-lista.png` | Publicaciones | Éxito: lista de `/posts` con 20+ elementos |
| `02-detalle.png` | Detalle | Navegación al tocar una publicación |
| `03-carga.png` | Publicaciones | `CircularProgressIndicator` mientras se espera la respuesta |
| `04-error.png` | Publicaciones | Error HTTP 500 con botón *Reintentar* |
| `05-vacio.png` | Publicaciones | Respuesta `[]` del API |
| `06-usuarios.png` | Usuarios | Ejemplo guiado `/users` |

## Casos manuales verificados

| # | Caso | Pasos | Resultado esperado | Estado |
| --- | --- | --- | --- | --- |
| 1 | Lista con datos | Abrir la app en **Publicaciones** | Se muestran título, resumen, usuario e id de cada publicación | Aprobado |
| 2 | Carga | Abrir la app con red lenta | Se muestra el indicador de carga y después la lista | Aprobado |
| 3 | Error sin conexión | Activar modo avión y abrir la app | Mensaje de error y botón *Reintentar* funcional | Aprobado |
| 4 | Error HTTP | Servidor que responde 500 | Mensaje `Error HTTP 500 al consultar /posts.` | Aprobado |
| 5 | Reintento | Tocar *Reintentar* con la red restablecida | Se ejecuta una nueva petición y se muestra la lista | Aprobado |
| 6 | Actualizar | Deslizar hacia abajo sobre la lista | `RefreshIndicator` gira y se vuelve a consultar el API | Aprobado |
| 7 | Detalle | Tocar una publicación | Se abre la pantalla de detalle con título y cuerpo completos | Aprobado |
| 8 | Lista vacía | API que responde `[]` | Se muestra el estado vacío | Aprobado |
| 9 | Ejemplo guiado | Ir a la pestaña **Usuarios** | Se listan nombre y correo de `/users` | Aprobado |

## Comandos ejecutados

```text
flutter analyze  →  No issues found!
flutter test     →  24 pruebas aprobadas
flutter build web --release → compilación correcta
```
