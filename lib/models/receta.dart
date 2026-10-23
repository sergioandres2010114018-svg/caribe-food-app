class Categoria {
  final String id;
  final String nombre;
  final String icono;
  final int orden;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.orden,
  });

  factory Categoria.fromJson(Map<String, dynamic> j) => Categoria(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        icono: (j['icono'] ?? 'restaurant') as String,
        orden: _entero(j['orden'], 0),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'nombre': nombre, 'icono': icono, 'orden': orden};
}

class Media {
  final String id;
  final String tipo; // 'imagen' o 'video'
  final String url;
  final String ruta;
  final String? descripcion;
  final int orden;

  const Media({
    required this.id,
    required this.tipo,
    required this.url,
    required this.ruta,
    this.descripcion,
    this.orden = 0,
  });

  bool get esVideo => tipo == 'video';

  factory Media.fromJson(Map<String, dynamic> j) => Media(
        id: j['id'].toString(),
        tipo: (j['tipo'] ?? 'imagen') as String,
        url: j['url'] as String,
        ruta: (j['ruta'] ?? '') as String,
        descripcion: j['descripcion'] as String?,
        orden: _entero(j['orden'], 0),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'url': url,
        'ruta': ruta,
        'descripcion': descripcion,
        'orden': orden,
      };
}

class Receta {
  final String id;
  final String titulo;
  final String categoria;
  final String region;
  final String descripcion;
  final int tiempoMin;
  final int porciones;
  final String dificultad;
  final List<String> ingredientes;
  final List<String> pasos;
  final String contexto;
  final String informante;
  final String? imagenPortada;
  final List<Media> media;

  const Receta({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.region = '',
    this.descripcion = '',
    this.tiempoMin = 30,
    this.porciones = 4,
    this.dificultad = 'Fácil',
    this.ingredientes = const [],
    this.pasos = const [],
    this.contexto = '',
    this.informante = '',
    this.imagenPortada,
    this.media = const [],
  });

  List<Media> get imagenes => media.where((m) => !m.esVideo).toList();
  List<Media> get videos => media.where((m) => m.esVideo).toList();

  /// Foto principal: la portada o, si no hay, la primera foto subida.
  String? get fotoPrincipal {
    if (imagenPortada != null && imagenPortada!.isNotEmpty) return imagenPortada;
    final fotos = imagenes;
    return fotos.isEmpty ? null : fotos.first.url;
  }

  factory Receta.fromJson(Map<String, dynamic> j) {
    final mediaJson = (j['receta_media'] ?? j['media'] ?? []) as List;
    final media = mediaJson
        .map((m) => Media.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));
    return Receta(
      id: j['id'] as String,
      titulo: j['titulo'] as String,
      categoria: j['categoria'] as String,
      region: (j['region'] ?? '') as String,
      descripcion: (j['descripcion'] ?? '') as String,
      tiempoMin: _entero(j['tiempo_min'], 30),
      porciones: _entero(j['porciones'], 4),
      dificultad: (j['dificultad'] ?? 'Fácil') as String,
      ingredientes: _lista(j['ingredientes']),
      pasos: _lista(j['pasos']),
      contexto: (j['contexto'] ?? '') as String,
      informante: (j['informante'] ?? '') as String,
      imagenPortada: j['imagen_portada'] as String?,
      media: media,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'categoria': categoria,
        'region': region,
        'descripcion': descripcion,
        'tiempo_min': tiempoMin,
        'porciones': porciones,
        'dificultad': dificultad,
        'ingredientes': ingredientes,
        'pasos': pasos,
        'contexto': contexto,
        'informante': informante,
        'imagen_portada': imagenPortada,
        'media': media.map((m) => m.toJson()).toList(),
      };

  /// Texto en minúsculas y sin tildes para búsquedas.
  String get textoBusqueda => normalizar(
      '$titulo $descripcion $region ${ingredientes.join(' ')} $categoria');
}

int _entero(dynamic v, int porDefecto) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? porDefecto;
  return porDefecto;
}

List<String> _lista(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}

String normalizar(String s) {
  const con = 'áéíóúüñÁÉÍÓÚÜÑ';
  const sin = 'aeiouunAEIOUUN';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = con.indexOf(ch);
    b.write(i >= 0 ? sin[i] : ch);
  }
  return b.toString().toLowerCase();
}

/// Convierte un título en un identificador: "Arroz con coco" -> "arroz-con-coco".
String crearId(String titulo) {
  final base = normalizar(titulo)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return base.isEmpty ? 'receta-${DateTime.now().millisecondsSinceEpoch}' : base;
}
