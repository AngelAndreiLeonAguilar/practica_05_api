import 'package:flutter/material.dart';

import '../models/post.dart';

/// Detalle de una publicación seleccionada en la lista.
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

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
                  label: Text('Publicación ${post.id}'),
                ),
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text('Usuario ${post.userId}'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              post.titulo,
              key: const Key('detalle-titulo'),
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              post.cuerpo,
              key: const Key('detalle-cuerpo'),
              style: tema.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
