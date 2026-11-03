import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/json_placeholder_api.dart';
import '../widgets/estados.dart';

/// Ejemplo guiado de la práctica: listado de usuarios de `/users`.
class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key, this.api});

  final JsonPlaceholderApi? api;

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late final JsonPlaceholderApi _api;
  late Future<List<Usuario>> _futuro;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? JsonPlaceholderApi();
    _futuro = _api.usuarios();
  }

  @override
  void dispose() {
    if (widget.api == null) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _recargar() async {
    final futuro = _api.usuarios();
    setState(() {
      _futuro = futuro;
    });
    try {
      await futuro;
    } catch (_) {
      // El error se representa con FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios REST'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const VistaCargando(mensaje: 'Cargando usuarios…');
          }
          if (snapshot.hasError) {
            return VistaError(
              mensaje: '${snapshot.error}',
              onReintentar: _recargar,
            );
          }
          final usuarios = snapshot.data ?? const <Usuario>[];
          if (usuarios.isEmpty) {
            return const VistaVacia(mensaje: 'El API no devolvió usuarios.');
          }
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.builder(
              key: const Key('lista-usuarios'),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: usuarios.length,
              itemBuilder: (context, indice) {
                final usuario = usuarios[indice];
                return ListTile(
                  key: Key('usuario-${usuario.id}'),
                  leading: CircleAvatar(child: Text('${usuario.id}')),
                  title: Text(usuario.nombre),
                  subtitle: Text(usuario.correo),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
