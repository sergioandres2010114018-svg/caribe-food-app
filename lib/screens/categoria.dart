import 'package:flutter/material.dart';

import '../models/receta.dart';
import '../services/repositorio.dart';
import '../widgets/tarjeta_receta.dart';

class PantallaCategoria extends StatelessWidget {
  final Categoria categoria;
  const PantallaCategoria({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return Scaffold(
      appBar: AppBar(title: Text(categoria.nombre)),
      body: ListenableBuilder(
        listenable: repo,
        builder: (_, __) {
          final lista = repo.porCategoria(categoria.id);
          if (lista.isEmpty) {
            return const Center(child: Text('Aún no hay recetas en esta categoría.'));
          }
          return CuadriculaRecetas(recetas: lista);
        },
      ),
    );
  }
}
