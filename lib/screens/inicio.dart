import 'package:flutter/material.dart';

import '../models/receta.dart';
import '../services/repositorio.dart';
import '../widgets/tarjeta_receta.dart';
import '../widgets/tema.dart';
import 'categoria.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        if (repo.cargando && repo.recetas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: repo.cargar,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Encabezado()),
              if (repo.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(repo.error!,
                        style: const TextStyle(color: Colores.rojo, fontSize: 13)),
                  ),
                ),
              const SliverToBoxAdapter(child: _Titulo('Categorías')),
              SliverToBoxAdapter(child: _Categorias(categorias: repo.categorias)),
              if (repo.recetas.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _Titulo('Receta del día')),
                SliverToBoxAdapter(child: _Destacada(receta: _recetaDelDia(repo.recetas))),
              ],
              SliverToBoxAdapter(
                child: _Titulo('Todas las recetas (${repo.recetas.length})'),
              ),
              CuadriculaRecetas(recetas: repo.recetas, comoSliver: true),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text('Fuente: ${repo.origen}',
                        style: const TextStyle(fontSize: 11, color: Colors.black45)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Receta _recetaDelDia(List<Receta> recetas) {
    final hoy = DateTime.now();
    final n = hoy.year * 400 + hoy.month * 31 + hoy.day;
    return recetas[n % recetas.length];
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colores.azul, Colores.turquesa],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/logo.png', width: 64, height: 64),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CaribeFood',
                    style: TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('El sabor del Caribe en tu cocina',
                    style: TextStyle(
                        color: Colores.amarillo,
                        fontSize: 15,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colores.azul)),
      );
}

class _Categorias extends StatelessWidget {
  final List<Categoria> categorias;
  const _Categorias({required this.categorias});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = categorias[i];
          final color = colorCategoria(c.id);
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PantallaCategoria(categoria: c),
            )),
            child: SizedBox(
              width: 84,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: color,
                    child: Icon(iconoCategoria(c.icono), color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 6),
                  Text(c.nombre,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Destacada extends StatelessWidget {
  final Receta receta;
  const _Destacada({required this.receta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(height: 260, child: TarjetaReceta(receta: receta)),
    );
  }
}
