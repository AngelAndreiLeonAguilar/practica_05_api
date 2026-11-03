import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/json_placeholder_api.dart';
import '../widgets/estados.dart';
import 'post_detail_page.dart';

/// Ejercicio evaluable: lista de publicaciones de `/posts`.
///
/// Representa los estados de carga, error, lista vacía y lista con datos,
/// permite actualizar con [RefreshIndicator] y navega al detalle.
class PostsPage extends StatefulWidget {
  const PostsPage({super.key, this.api});

  /// Permite inyectar un cliente distinto (por ejemplo en pruebas).
  final JsonPlaceholderApi? api;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late final JsonPlaceholderApi _api;
  late Future<List<Post>> _futuro;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? JsonPlaceholderApi();
    _futuro = _api.posts();
  }

  @override
  void dispose() {
    if (widget.api == null) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _recargar() async {
    final futuro = _api.posts();
    setState(() {
      _futuro = futuro;
    });
    try {
      await futuro;
    } catch (_) {
      // El error se representa con FutureBuilder; aquí solo se espera.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        actions: [
          IconButton(
            key: const Key('boton-actualizar'),
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const VistaCargando(mensaje: 'Cargando publicaciones…');
          }
          if (snapshot.hasError) {
            return VistaError(
              mensaje: '${snapshot.error}',
              onReintentar: _recargar,
            );
          }
          final posts = snapshot.data ?? const <Post>[];
          if (posts.isEmpty) {
            return const VistaVacia(
              mensaje: 'El API no devolvió publicaciones.',
            );
          }
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              key: const Key('lista-posts'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, indice) {
                final post = posts[indice];
                return _TarjetaPost(
                  post: post,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaPost extends StatelessWidget {
  const _TarjetaPost({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      key: Key('post-${post.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colores.primaryContainer,
                foregroundColor: colores.onPrimaryContainer,
                child: Text('${post.id}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.resumen,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Usuario ${post.userId}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colores.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
