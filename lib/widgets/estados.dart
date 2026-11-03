import 'package:flutter/material.dart';

/// Indicador de carga con mensaje, usado mientras se espera la respuesta HTTP.
class VistaCargando extends StatelessWidget {
  const VistaCargando({super.key, this.mensaje = 'Cargando información…'});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('estado-carga'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(mensaje, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Mensaje de error con acción para reintentar la petición.
class VistaError extends StatelessWidget {
  const VistaError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Center(
      key: const Key('estado-error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: colores.error),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los datos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('boton-reintentar'),
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado para respuestas exitosas sin elementos.
class VistaVacia extends StatelessWidget {
  const VistaVacia({
    super.key,
    this.mensaje = 'No hay elementos para mostrar.',
  });

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('estado-vacio'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
