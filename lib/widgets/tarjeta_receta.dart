import 'package:flutter/material.dart';

import '../models/receta.dart';
import '../screens/detalle.dart';
import '../services/favoritos.dart';
import 'imagen_receta.dart';
import 'tema.dart';

class TarjetaReceta extends StatelessWidget {
  final Receta receta;
  const TarjetaReceta({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    final fav = Favoritos.instancia;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PantallaDetalle(recetaId: receta.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImagenReceta(receta: receta),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: ListenableBuilder(
                      listenable: fav,
                      builder: (_, __) => IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Favorito',
                        onPressed: () => fav.alternar(receta.id),
                        icon: Icon(
                          fav.es(receta.id) ? Icons.favorite : Icons.favorite_border,
                          color: Colores.rojo,
                        ),
                      ),
                    ),
                  ),
                  if (receta.videos.isNotEmpty)
                    const Positioned(
                      left: 8,
                      bottom: 8,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.play_arrow, size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colores.cafe),
                      const SizedBox(width: 3),
                      Text('${receta.tiempoMin} min',
                          style: const TextStyle(fontSize: 12, color: Colores.cafe)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          receta.dificultad,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colores.cafe),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuadrícula de recetas que se adapta al ancho de la pantalla.
class CuadriculaRecetas extends StatelessWidget {
  final List<Receta> recetas;
  final bool comoSliver;
  const CuadriculaRecetas({super.key, required this.recetas, this.comoSliver = false});

  static const _delegado = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.78,
  );

  @override
  Widget build(BuildContext context) {
    if (comoSliver) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        sliver: SliverGrid(
          gridDelegate: _delegado,
          delegate: SliverChildBuilderDelegate(
            (_, i) => TarjetaReceta(receta: recetas[i]),
            childCount: recetas.length,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: _delegado,
      itemCount: recetas.length,
      itemBuilder: (_, i) => TarjetaReceta(receta: recetas[i]),
    );
  }
}
