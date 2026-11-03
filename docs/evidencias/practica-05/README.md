# Evidencias · Práctica 05

Capturas generadas desde la interfaz real de la aplicación con
`flutter test tool/capturas/evidencias_test.dart --update-goldens`
(las imágenes se producen con el mismo árbol de widgets que se ejecuta en la app).

| Archivo | Pantalla | Estado |
| --- | --- | --- |
| `01-lista.png` | Artículos | Éxito: resultados de Wikipedia en español |
| `02-detalle.png` | Detalle | Navegación al tocar un artículo |
| `03-carga.png` | Artículos | `CircularProgressIndicator` mientras se espera la respuesta |
| `04-error.png` | Artículos | Error HTTP 500 con botón *Reintentar* |
| `05-vacio.png` | Artículos | Búsqueda sin resultados |
| `06-usuarios.png` | Usuarios | Ejemplo guiado `/users` (JSONPlaceholder) |

## Casos manuales verificados

| # | Caso | Pasos | Resultado esperado | Estado |
| --- | --- | --- | --- | --- |
| 1 | Lista con datos | Abrir la app en **Artículos** | Se muestran título y resumen de 20 artículos | Aprobado |
| 2 | Carga | Abrir la app con red lenta | Se muestra «Buscando «México»…» y después la lista | Aprobado |
| 3 | Error sin conexión | Activar modo avión y abrir la app | Mensaje de error y botón *Reintentar* funcional | Aprobado |
| 4 | Error HTTP | Servidor que responde 500 | Mensaje `Error HTTP 500 al consultar la Wikipedia.` | Aprobado |
| 5 | Reintento | Tocar *Reintentar* con la red restablecida | Nueva petición y lista visible | Aprobado |
| 6 | Actualizar | Deslizar hacia abajo sobre la lista | `RefreshIndicator` gira y vuelve a consultar | Aprobado |
| 7 | Buscar | Escribir «Oaxaca» y enviar | La petición usa `gsrsearch=Oaxaca` y cambia la lista | Aprobado |
| 8 | Detalle | Tocar un artículo | Se abre el detalle con título y texto completos | Aprobado |
| 9 | Lista vacía | Buscar un término sin resultados | Estado «No se encontraron artículos…» | Aprobado |
| 10 | Ejemplo guiado | Ir a la pestaña **Usuarios** | Se listan nombre y correo de `/users` | Aprobado |

## Comandos ejecutados

```text
flutter analyze  →  No issues found!
flutter test     →  28 pruebas aprobadas
```
