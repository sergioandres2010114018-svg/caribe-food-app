import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/receta.dart';

/// Lugar único donde la app obtiene y guarda recetas, fotos y videos.
///
/// Orden de carga:
///   1. Base de datos en línea (Supabase), si está configurada y hay internet.
///   2. Última copia guardada en el teléfono (para usar sin conexión).
///   3. Catálogo incluido dentro de la app (assets/data/recetas.json).
class Repositorio extends ChangeNotifier {
  Repositorio._();
  static final Repositorio instancia = Repositorio._();

  static const _claveCache = 'cache_recetas_v1';

  /// Se pone en true en main.dart si Supabase arrancó bien.
  static bool supabaseListo = false;

  List<Categoria> categorias = [];
  List<Receta> recetas = [];
  bool cargando = false;
  String origen = '';
  String? error;

  SupabaseClient? get _db => supabaseListo ? Supabase.instance.client : null;
  bool get enLinea => _db != null;
  User? get usuario => _db?.auth.currentUser;

  Categoria? categoria(String id) {
    for (final c in categorias) {
      if (c.id == id) return c;
    }
    return null;
  }

  Receta? receta(String id) {
    for (final r in recetas) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<Receta> porCategoria(String id) =>
      recetas.where((r) => r.categoria == id).toList();

  List<Receta> buscar(String texto) {
    final t = normalizar(texto.trim());
    if (t.isEmpty) return recetas;
    final palabras = t.split(RegExp(r'\s+'));
    return recetas
        .where((r) => palabras.every((p) => r.textoBusqueda.contains(p)))
        .toList();
  }

  // ---------------------------------------------------------------- CARGA

  Future<void> cargar() async {
    cargando = true;
    error = null;
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        final cats = await db.from('categorias').select().order('orden');
        final recs = await db
            .from('recetas')
            .select('*, receta_media(*)')
            .order('titulo')
            .timeout(const Duration(seconds: 15));
        categorias = (cats as List)
            .map((c) => Categoria.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList();
        recetas = (recs as List)
            .map((r) => Receta.fromJson(Map<String, dynamic>.from(r as Map)))
            .toList();
        origen = 'En línea';
        await _guardarCache();
        _terminar();
        return;
      } catch (e) {
        error = 'Sin conexión con la base de datos. Mostrando recetas guardadas.';
        debugPrint('Error cargando Supabase: $e');
      }
    }

    if (await _leerCache()) {
      origen = 'Guardado en el teléfono';
    } else {
      await _leerIncluido();
      origen = 'Catálogo incluido';
    }
    _terminar();
  }

  void _terminar() {
    categorias.sort((a, b) => a.orden.compareTo(b.orden));
    cargando = false;
    notifyListeners();
  }

  Future<void> _guardarCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _claveCache,
        jsonEncode({
          'categorias': categorias.map((c) => c.toJson()).toList(),
          'recetas': recetas.map((r) => r.toJson()).toList(),
        }),
      );
    } catch (_) {}
  }

  Future<bool> _leerCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString(_claveCache);
      if (texto == null) return false;
      _cargarDesdeMapa(jsonDecode(texto) as Map<String, dynamic>);
      return recetas.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _leerIncluido() async {
    final texto = await rootBundle.loadString('assets/data/recetas.json');
    _cargarDesdeMapa(jsonDecode(texto) as Map<String, dynamic>);
  }

  void _cargarDesdeMapa(Map<String, dynamic> datos) {
    categorias = (datos['categorias'] as List)
        .map((c) => Categoria.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
    recetas = (datos['recetas'] as List)
        .map((r) => Receta.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  // ------------------------------------------------------------ SESIÓN

  Future<void> iniciarSesion(String correo, String clave) async {
    await _requerirDb().auth.signInWithPassword(email: correo, password: clave);
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _db?.auth.signOut();
    notifyListeners();
  }

  SupabaseClient _requerirDb() {
    final db = _db;
    if (db == null) {
      throw Exception(
          'La base de datos no está configurada en este APK. Revisa la guía (Secrets de GitHub).');
    }
    return db;
  }

  // ------------------------------------------------------- ESCRITURA

  Future<void> guardarReceta(Receta r) async {
    final datos = r.toJson()..remove('media');
    await _requerirDb().from('recetas').upsert(datos);
    await cargar();
  }

  Future<void> eliminarReceta(Receta r) async {
    final db = _requerirDb();
    final rutas = r.media.map((m) => m.ruta).where((p) => p.isNotEmpty).toList();
    if (rutas.isNotEmpty) {
      await db.storage.from(Config.bucketMedia).remove(rutas);
    }
    await db.from('recetas').delete().eq('id', r.id);
    await cargar();
  }

  /// Sube una foto o video a la base de datos y lo asocia a la receta.
  Future<void> subirArchivo({
    required Receta receta,
    required XFile archivo,
    required bool esVideo,
    String? descripcion,
  }) async {
    final db = _requerirDb();
    final tamano = await archivo.length();
    if (tamano > Config.maxBytesArchivo) {
      final mb = (tamano / (1024 * 1024)).toStringAsFixed(1);
      throw Exception(
          'El archivo pesa $mb MB. El máximo es 50 MB. Graba un video más corto o de menor calidad.');
    }

    final ext = _extension(archivo.path, esVideo);
    final ruta = '${receta.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await db.storage.from(Config.bucketMedia).upload(
          ruta,
          File(archivo.path),
          fileOptions: FileOptions(contentType: _tipoMime(ext), upsert: false),
        );
    final url = db.storage.from(Config.bucketMedia).getPublicUrl(ruta);

    await db.from('receta_media').insert({
      'receta_id': receta.id,
      'tipo': esVideo ? 'video' : 'imagen',
      'url': url,
      'ruta': ruta,
      'descripcion': descripcion,
      'orden': receta.media.length,
    });

    if (!esVideo && (receta.imagenPortada == null || receta.imagenPortada!.isEmpty)) {
      await db.from('recetas').update({'imagen_portada': url}).eq('id', receta.id);
    }
    await cargar();
  }

  Future<void> usarComoPortada(Receta receta, Media m) async {
    await _requerirDb()
        .from('recetas')
        .update({'imagen_portada': m.url}).eq('id', receta.id);
    await cargar();
  }

  Future<void> eliminarMedia(Receta receta, Media m) async {
    final db = _requerirDb();
    if (m.ruta.isNotEmpty) {
      await db.storage.from(Config.bucketMedia).remove([m.ruta]);
    }
    await db.from('receta_media').delete().eq('id', m.id);
    if (receta.imagenPortada == m.url) {
      await db.from('recetas').update({'imagen_portada': null}).eq('id', receta.id);
    }
    await cargar();
  }

  String _extension(String ruta, bool esVideo) {
    final punto = ruta.lastIndexOf('.');
    final ext = punto >= 0 ? ruta.substring(punto + 1).toLowerCase() : '';
    const validas = ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', '3gp'];
    if (validas.contains(ext)) return ext;
    return esVideo ? 'mp4' : 'jpg';
  }

  String _tipoMime(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case '3gp':
        return 'video/3gpp';
      default:
        return 'image/jpeg';
    }
  }
}
