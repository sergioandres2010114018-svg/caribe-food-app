import 'package:flutter/material.dart';

import '../widgets/tema.dart';

class PantallaCultura extends StatelessWidget {
  const PantallaCultura({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cocina y cultura del Caribe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Bloque(
            icono: Icons.waves,
            color: Colores.turquesa,
            titulo: 'Una cocina de río, mar y sabana',
            texto:
                'La cocina del Caribe colombiano nace del encuentro de las culturas indígena, '
                'africana y europea. En los pueblos ribereños del Magdalena, como Pijiño del Carmen, '
                'el pescado de río y de ciénaga —bocachico, bagre, mojarra— es la base de la mesa, '
                'acompañado de yuca, plátano, ñame y arroz.',
          ),
          _Bloque(
            icono: Icons.spa,
            color: Colores.verde,
            titulo: 'Ingredientes de la tierra',
            texto:
                'El coco, el plátano, la yuca, el ñame, el maíz, el queso costeño y el suero son '
                'protagonistas. Muchos se cultivan en los patios y parcelas de la región y se '
                'transforman en arroces, sopas, fritos y dulces.',
          ),
          _Bloque(
            icono: Icons.local_fire_department,
            color: Colores.rojo,
            titulo: 'El fogón y el caldero',
            texto:
                'Tradicionalmente se cocina en fogón de leña y caldero de hierro o aluminio. '
                'El sabor ahumado y el "pegao" del arroz son parte de la identidad de nuestras comidas.',
          ),
          _Bloque(
            icono: Icons.family_restroom,
            color: Colores.naranja,
            titulo: 'Un saber que se hereda',
            texto:
                'La mayoría de estas recetas no están escritas: se aprenden mirando a las abuelas y '
                'madres. CaribeFood App nace para documentarlas, con fotos y videos, antes de que se '
                'pierdan, reconociendo siempre a quien las comparte.',
          ),
          _Bloque(
            icono: Icons.account_balance,
            color: Colores.cafe,
            titulo: 'Patrimonio cultural',
            texto:
                'El Ministerio de Cultura reconoce las cocinas tradicionales como parte del patrimonio '
                'cultural de Colombia, en su Política para el conocimiento, la salvaguardia y el '
                'fomento de la alimentación y las cocinas tradicionales (2012).',
          ),
          SizedBox(height: 12),
          _SobreProyecto(),
        ],
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String texto;
  const _Bloque({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icono, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold, color: Colores.azul)),
                    const SizedBox(height: 6),
                    Text(texto, style: const TextStyle(fontSize: 15, height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SobreProyecto extends StatelessWidget {
  const _SobreProyecto();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colores.azul,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sobre CaribeFood App',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Proyecto productivo SENA — Técnico en Programación de Aplicaciones para '
            'Dispositivos Móviles. Institución Educativa Técnica Departamental Pijiño del Carmen '
            '(Magdalena), grupo 3321831.',
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
          SizedBox(height: 10),
          Text('Equipo',
              style: TextStyle(color: Colores.amarillo, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            'Joselin Paola Farelo Sanez · Luisa Fernanda Machado López · '
            'Luis David Triviño Morales · Michelle Alejandra López Luna · '
            'Yeiner Andrés Martínez Alvarado\n'
            'Instructor: Sergio Andrés Caro Arrieta',
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
          SizedBox(height: 10),
          Text('"El sabor del Caribe en tu cocina"',
              style: TextStyle(color: Colores.amarillo, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
