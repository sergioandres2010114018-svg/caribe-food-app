import 'package:flutter/material.dart';

import '../services/repositorio.dart';
import '../widgets/tarjeta_receta.dart';
import '../widgets/tema.dart';

class PantallaBuscar extends StatefulWidget {
  const PantallaBuscar({super.key});

  @override
  State<PantallaBuscar> createState() => _PantallaBuscarState();
}

class _PantallaBuscarState extends State<PantallaBuscar> {
  final _control = TextEditingController();
  String _categoria = '';

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar recetas')),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          var resultados = repo.buscar(_control.text);
          if (_categoria.isNotEmpty) {
            resultados = resultados.where((r) => r.categoria == _categoria).toList();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _control,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Plato o ingrediente: coco, yuca, pescado…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _control.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(_control.clear),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Todas'),
                        selected: _categoria.isEmpty,
                        onSelected: (_) => setState(() => _categoria = ''),
                      ),
                    ),
                    for (final c in repo.categorias)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c.nombre),
                          selected: _categoria == c.id,
                          selectedColor: Colores.amarillo,
                          onSelected: (_) => setState(() => _categoria = c.id),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: resultados.isEmpty
                    ? const Center(child: Text('No encontramos recetas con esa búsqueda.'))
                    : CuadriculaRecetas(recetas: resultados),
              ),
            ],
          );
        },
      ),
    );
  }
}
