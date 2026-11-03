import 'package:flutter/material.dart';

import '../models/articulo.dart';
import '../services/wikipedia_api.dart';
import '../widgets/estados.dart';
import 'articulo_detalle_page.dart';

/// Pantalla principal: artículos de la Wikipedia en español.
///
/// Representa los estados de carga, error, lista vacía y lista con datos,
/// permite actualizar con [RefreshIndicator] y navega al detalle.
class ArticulosPage extends StatefulWidget {
  const ArticulosPage({super.key, this.api, this.consultaInicial = 'México'});

  /// Permite inyectar un cliente distinto (por ejemplo en pruebas).
  final WikipediaApi? api;

  /// Tema que se consulta al abrir la pantalla.
  final String consultaInicial;

  @override
  State<ArticulosPage> createState() => _ArticulosPageState();
}

class _ArticulosPageState extends State<ArticulosPage> {
  late final WikipediaApi _api;
  late final TextEditingController _controlador;
  late Future<List<Articulo>> _futuro;
  late String _consulta;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? WikipediaApi();
    _consulta = widget.consultaInicial;
    _controlador = TextEditingController(text: _consulta);
    _futuro = _api.buscar(_consulta);
  }

  @override
  void dispose() {
    _controlador.dispose();
    if (widget.api == null) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _recargar() async {
    final futuro = _api.buscar(_consulta);
    setState(() {
      _futuro = futuro;
    });
    try {
      await futuro;
    } catch (_) {
      // El error se representa con FutureBuilder; aquí solo se espera.
    }
  }

  void _buscar(String texto) {
    final consulta = texto.trim();
    if (consulta.isEmpty || consulta == _consulta) return;
    _consulta = consulta;
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            key: const Key('boton-actualizar'),
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              key: const Key('campo-busqueda'),
              controller: _controlador,
              textInputAction: TextInputAction.search,
              onSubmitted: _buscar,
              decoration: InputDecoration(
                hintText: 'Buscar en Wikipedia…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Articulo>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return VistaCargando(mensaje: 'Buscando «$_consulta»…');
          }
          if (snapshot.hasError) {
            return VistaError(
              mensaje: '${snapshot.error}',
              onReintentar: _recargar,
            );
          }
          final articulos = snapshot.data ?? const <Articulo>[];
          if (articulos.isEmpty) {
            return VistaVacia(
              mensaje: 'No se encontraron artículos para «$_consulta».',
            );
          }
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              key: const Key('lista-articulos'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: articulos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, indice) {
                final articulo = articulos[indice];
                return _TarjetaArticulo(
                  articulo: articulo,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ArticuloDetallePage(articulo: articulo),
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

class _TarjetaArticulo extends StatelessWidget {
  const _TarjetaArticulo({required this.articulo, required this.onTap});

  final Articulo articulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      key: Key('articulo-${articulo.id}'),
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
                child: const Icon(Icons.menu_book_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      articulo.resumen,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
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
