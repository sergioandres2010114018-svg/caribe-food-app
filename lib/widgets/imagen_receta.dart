import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/receta.dart';
import '../services/repositorio.dart';
import 'tema.dart';

/// Muestra la foto de la receta. Si no hay foto todavía, dibuja un fondo de
/// color con el ícono de su categoría.
class ImagenReceta extends StatelessWidget {
  final Receta receta;
  final double? altura;
  final BoxFit ajuste;

  const ImagenReceta({
    super.key,
    required this.receta,
    this.altura,
    this.ajuste = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = receta.fotoPrincipal;
    if (url == null) return _sinFoto();
    return CachedNetworkImage(
      imageUrl: url,
      height: altura,
      width: double.infinity,
      fit: ajuste,
      placeholder: (_, __) => _sinFoto(cargando: true),
      errorWidget: (_, __, ___) => _sinFoto(),
    );
  }

  Widget _sinFoto({bool cargando = false}) {
    final cat = Repositorio.instancia.categoria(receta.categoria);
    final color = colorCategoria(receta.categoria);
    return Container(
      height: altura,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colores.amarillo, 0.45)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: cargando
            ? const CircularProgressIndicator(color: Colors.white)
            : Icon(iconoCategoria(cat?.icono ?? ''),
                size: 56, color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}
