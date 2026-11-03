import 'package:flutter/material.dart';

import '../models/articulo.dart';

/// Detalle de un artículo seleccionado en la lista.
class ArticuloDetallePage extends StatelessWidget {
  const ArticuloDetallePage({super.key, required this.articulo});

  final Articulo articulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.tag, size: 18),
                  label: Text('Artículo ${articulo.id}'),
                ),
                const Chip(
                  avatar: Icon(Icons.menu_book_outlined, size: 18),
                  label: Text('Wikipedia en español'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              articulo.titulo,
              key: const Key('detalle-titulo'),
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              articulo.extracto,
              key: const Key('detalle-extracto'),
              style: tema.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
