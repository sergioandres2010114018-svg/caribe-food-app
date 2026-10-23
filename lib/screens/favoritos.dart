import 'package:flutter/material.dart';

import '../services/favoritos.dart';
import '../services/repositorio.dart';
import '../widgets/tarjeta_receta.dart';

class PantallaFavoritos extends StatelessWidget {
  const PantallaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    final fav = Favoritos.instancia;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: ListenableBuilder(
        listenable: Listenable.merge([repo, fav]),
        builder: (_, __) {
          final lista = repo.recetas.where((r) => fav.es(r.id)).toList();
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Toca el corazón ♥ en una receta para guardarla aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return CuadriculaRecetas(recetas: lista);
        },
      ),
    );
  }
}
