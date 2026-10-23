import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/receta.dart';
import '../services/favoritos.dart';
import '../services/repositorio.dart';
import '../widgets/imagen_receta.dart';
import '../widgets/tema.dart';
import 'visor.dart';

class PantallaDetalle extends StatelessWidget {
  final String recetaId;
  const PantallaDetalle({super.key, required this.recetaId});

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return ListenableBuilder(
      listenable: Listenable.merge([repo, Favoritos.instancia]),
      builder: (context, _) {
        final r = repo.receta(recetaId);
        if (r == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Receta no encontrada.')),
          );
        }
        return Scaffold(body: _Contenido(receta: r));
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  final Receta receta;
  const _Contenido({required this.receta});

  @override
  Widget build(BuildContext context) {
    final r = receta;
    final fav = Favoritos.instancia;
    final cat = Repositorio.instancia.categoria(r.categoria);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 280,
          actions: [
            IconButton(
              tooltip: 'Favorito',
              onPressed: () => fav.alternar(r.id),
              icon: Icon(fav.es(r.id) ? Icons.favorite : Icons.favorite_border),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(r.titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
            background: ImagenReceta(receta: r),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (cat != null)
                    _Dato(icono: iconoCategoria(cat.icono), texto: cat.nombre),
                  _Dato(icono: Icons.schedule, texto: '${r.tiempoMin} min'),
                  _Dato(icono: Icons.people, texto: '${r.porciones} porciones'),
                  _Dato(icono: Icons.signal_cellular_alt, texto: r.dificultad),
                  if (r.region.isNotEmpty) _Dato(icono: Icons.place, texto: r.region),
                ],
              ),
              if (r.descripcion.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(r.descripcion, style: const TextStyle(fontSize: 16, height: 1.4)),
              ],
              if (r.imagenes.isNotEmpty) ...[
                const _Seccion('Fotos'),
                _Galeria(fotos: r.imagenes),
              ],
              if (r.videos.isNotEmpty) ...[
                const _Seccion('Videos de preparación'),
                for (final v in r.videos) _TarjetaVideo(video: v, titulo: r.titulo),
              ],
              const _Seccion('Ingredientes'),
              _ListaIngredientes(ingredientes: r.ingredientes),
              const _Seccion('Preparación'),
              for (var i = 0; i < r.pasos.length; i++) _Paso(numero: i + 1, texto: r.pasos[i]),
              if (r.contexto.isNotEmpty) ...[
                const _Seccion('Historia y cultura'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colores.amarillo.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colores.amarillo),
                  ),
                  child: Text(r.contexto, style: const TextStyle(fontSize: 15, height: 1.45)),
                ),
              ],
              if (r.informante.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.record_voice_over, size: 18, color: Colores.cafe),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Compartida por: ${r.informante}',
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, color: Colores.cafe)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icono, size: 18, color: Colores.azul),
        label: Text(texto),
        backgroundColor: Colors.white,
      );
}

class _Seccion extends StatelessWidget {
  final String titulo;
  const _Seccion(this.titulo);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(titulo,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colores.azul)),
      );
}

class _ListaIngredientes extends StatefulWidget {
  final List<String> ingredientes;
  const _ListaIngredientes({required this.ingredientes});

  @override
  State<_ListaIngredientes> createState() => _ListaIngredientesState();
}

class _ListaIngredientesState extends State<_ListaIngredientes> {
  final Set<int> _listos = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < widget.ingredientes.length; i++)
            CheckboxListTile(
              dense: true,
              value: _listos.contains(i),
              activeColor: Colores.verde,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) => setState(() => v == true ? _listos.add(i) : _listos.remove(i)),
              title: Text(
                widget.ingredientes[i],
                style: TextStyle(
                  fontSize: 15,
                  decoration: _listos.contains(i) ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final int numero;
  final String texto;
  const _Paso({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colores.naranja,
              child: Text('$numero',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(texto, style: const TextStyle(fontSize: 15, height: 1.45)),
              ),
            ),
          ],
        ),
      );
}

class _Galeria extends StatelessWidget {
  final List<Media> fotos;
  const _Galeria({required this.fotos});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VisorFotos(fotos: fotos, inicial: i),
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: fotos[i].url,
              width: 160,
              height: 130,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 160, color: Colors.black12),
              errorWidget: (_, __, ___) =>
                  Container(width: 160, color: Colors.black12, child: const Icon(Icons.broken_image)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaVideo extends StatelessWidget {
  final Media video;
  final String titulo;
  const _TarjetaVideo({required this.video, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colores.rojo,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
        title: Text(video.descripcion?.isNotEmpty == true ? video.descripcion! : 'Ver video'),
        subtitle: const Text('Toca para reproducir'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ReproductorVideo(url: video.url, titulo: titulo),
        )),
      ),
    );
  }
}
