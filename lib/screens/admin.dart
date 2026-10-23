import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/receta.dart';
import '../services/repositorio.dart';
import '../widgets/imagen_receta.dart';
import '../widgets/tema.dart';
import 'visor.dart';

/// Zona del equipo: iniciar sesión y subir recetas, fotos y videos.
class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        if (!repo.enLinea) return const _SinBaseDeDatos();
        if (repo.usuario == null) return const _Login();
        return const _ListaAdmin();
      },
    );
  }
}

class _SinBaseDeDatos extends StatelessWidget {
  const _SinBaseDeDatos();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Subir recetas')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colores.cafe),
              SizedBox(height: 16),
              Text(
                'Este APK se compiló sin conexión a la base de datos.\n\n'
                'Para subir fotos y videos, agrega SUPABASE_URL y SUPABASE_ANON_KEY en los '
                'Secrets del repositorio de GitHub y vuelve a generar el APK '
                '(ver GUIA.md).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ],
          ),
        ),
      );
}

class _Login extends StatefulWidget {
  const _Login();

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await Repositorio.instancia.iniciarSesion(_correo.text.trim(), _clave.text);
    } catch (e) {
      setState(() => _error = 'No se pudo iniciar sesión. Revisa el correo y la contraseña.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Equipo CaribeFood')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.lock_person, size: 64, color: Colores.azul),
            const SizedBox(height: 12),
            const Text(
              'Solo el equipo del proyecto puede subir recetas, fotos y videos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Correo', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clave,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Contraseña', prefixIcon: Icon(Icons.key)),
              onSubmitted: (_) => _entrar(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colores.rojo)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _enviando ? null : _entrar,
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
}

class _ListaAdmin extends StatelessWidget {
  const _ListaAdmin();

  @override
  Widget build(BuildContext context) {
    final repo = Repositorio.instancia;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar recetas'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: repo.cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colores.naranja,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditorReceta()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva receta'),
      ),
      body: RefreshIndicator(
        onRefresh: repo.cargar,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: repo.recetas.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Sesión: ${repo.usuario?.email ?? ''}',
                    style: const TextStyle(color: Colores.cafe)),
              );
            }
            final r = repo.recetas[i - 1];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 56, height: 56, child: ImagenReceta(receta: r)),
              ),
              title: Text(r.titulo),
              subtitle: Text('${r.imagenes.length} fotos · ${r.videos.length} videos'),
              trailing: const Icon(Icons.edit),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditorReceta(recetaId: r.id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EditorReceta extends StatefulWidget {
  final String? recetaId;
  const EditorReceta({super.key, this.recetaId});

  @override
  State<EditorReceta> createState() => _EditorRecetaState();
}

class _EditorRecetaState extends State<EditorReceta> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _region = TextEditingController();
  final _descripcion = TextEditingController();
  final _tiempo = TextEditingController(text: '30');
  final _porciones = TextEditingController(text: '4');
  final _ingredientes = TextEditingController();
  final _pasos = TextEditingController();
  final _contexto = TextEditingController();
  final _informante = TextEditingController();
  final _picker = ImagePicker();

  String? _id;
  String _categoria = '';
  String _dificultad = 'Fácil';
  bool _ocupado = false;
  String _mensajeOcupado = '';

  final _repo = Repositorio.instancia;

  @override
  void initState() {
    super.initState();
    _id = widget.recetaId;
    final r = _id == null ? null : _repo.receta(_id!);
    if (r != null) {
      _titulo.text = r.titulo;
      _region.text = r.region;
      _descripcion.text = r.descripcion;
      _tiempo.text = '${r.tiempoMin}';
      _porciones.text = '${r.porciones}';
      _ingredientes.text = r.ingredientes.join('\n');
      _pasos.text = r.pasos.join('\n');
      _contexto.text = r.contexto;
      _informante.text = r.informante;
      _categoria = r.categoria;
      _dificultad = r.dificultad;
    } else if (_repo.categorias.isNotEmpty) {
      _categoria = _repo.categorias.first.id;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titulo, _region, _descripcion, _tiempo, _porciones,
      _ingredientes, _pasos, _contexto, _informante,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _lineas(String t) =>
      t.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  Future<void> _ejecutar(String mensaje, Future<void> Function() tarea,
      {String? exito}) async {
    setState(() {
      _ocupado = true;
      _mensajeOcupado = mensaje;
    });
    try {
      await tarea();
      if (mounted && exito != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito)));
      }
    } catch (e) {
      if (mounted) {
        final texto = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colores.rojo, content: Text('Error: $texto')),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final existente = _id == null ? null : _repo.receta(_id!);
    var id = _id ?? crearId(_titulo.text);
    if (_id == null && _repo.receta(id) != null) {
      id = '$id-${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
    final receta = Receta(
      id: id,
      titulo: _titulo.text.trim(),
      categoria: _categoria,
      region: _region.text.trim(),
      descripcion: _descripcion.text.trim(),
      tiempoMin: int.tryParse(_tiempo.text) ?? 30,
      porciones: int.tryParse(_porciones.text) ?? 4,
      dificultad: _dificultad,
      ingredientes: _lineas(_ingredientes.text),
      pasos: _lineas(_pasos.text),
      contexto: _contexto.text.trim(),
      informante: _informante.text.trim(),
      imagenPortada: existente?.imagenPortada,
    );
    await _ejecutar('Guardando receta…', () async {
      await _repo.guardarReceta(receta);
      _id = id;
    }, exito: 'Receta guardada. Ya puedes agregar fotos y videos.');
  }

  Future<void> _agregar({required bool video, required ImageSource fuente}) async {
    final receta = _id == null ? null : _repo.receta(_id!);
    if (receta == null) return;
    final XFile? archivo = video
        ? await _picker.pickVideo(source: fuente, maxDuration: const Duration(minutes: 3))
        : await _picker.pickImage(source: fuente, maxWidth: 1600, imageQuality: 82);
    if (archivo == null) return;
    await _ejecutar(
      video ? 'Subiendo video… puede tardar unos minutos' : 'Subiendo foto…',
      () => _repo.subirArchivo(receta: receta, archivo: archivo, esVideo: video),
      exito: video ? 'Video subido' : 'Foto subida',
    );
  }

  Future<void> _eliminarReceta() async {
    final receta = _id == null ? null : _repo.receta(_id!);
    if (receta == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Eliminar receta?'),
        content: Text('Se borrarán "${receta.titulo}" y todas sus fotos y videos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colores.rojo),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _ejecutar('Eliminando…', () => _repo.eliminarReceta(receta));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final receta = _id == null ? null : _repo.receta(_id!);
        final categorias = _repo.categorias;
        if (_categoria.isEmpty && categorias.isNotEmpty) _categoria = categorias.first.id;
        return Scaffold(
          appBar: AppBar(
            title: Text(receta == null ? 'Nueva receta' : 'Editar receta'),
            actions: [
              if (receta != null)
                IconButton(
                  tooltip: 'Eliminar receta',
                  onPressed: _ocupado ? null : _eliminarReceta,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: Stack(
            children: [
              Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    if (receta != null) ...[
                      _SeccionMedia(
                        receta: receta,
                        ocupado: _ocupado,
                        onAgregar: _agregar,
                        onPortada: (m) => _ejecutar(
                            'Actualizando…', () => _repo.usarComoPortada(receta, m),
                            exito: 'Portada actualizada'),
                        onEliminar: (m) => _ejecutar(
                            'Eliminando…', () => _repo.eliminarMedia(receta, m),
                            exito: 'Archivo eliminado'),
                      ),
                      const Divider(height: 32),
                    ],
                    _campo(_titulo, 'Nombre del plato *', requerido: true),
                    DropdownButtonFormField<String>(
                      initialValue: categorias.any((c) => c.id == _categoria) ? _categoria : null,
                      decoration: const InputDecoration(labelText: 'Categoría *'),
                      items: [
                        for (final c in categorias)
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                      ],
                      validator: (v) => v == null ? 'Elige una categoría' : null,
                      onChanged: (v) => setState(() => _categoria = v ?? _categoria),
                    ),
                    const SizedBox(height: 12),
                    _campo(_region, 'Región o municipio'),
                    _campo(_descripcion, 'Descripción corta', lineas: 2),
                    Row(
                      children: [
                        Expanded(child: _campo(_tiempo, 'Tiempo (min)', numero: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _campo(_porciones, 'Porciones', numero: true)),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: const ['Fácil', 'Media', 'Difícil'].contains(_dificultad)
                          ? _dificultad
                          : 'Fácil',
                      decoration: const InputDecoration(labelText: 'Dificultad'),
                      items: const [
                        DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
                      ],
                      onChanged: (v) => setState(() => _dificultad = v ?? 'Fácil'),
                    ),
                    const SizedBox(height: 12),
                    _campo(_ingredientes, 'Ingredientes (uno por línea) *',
                        lineas: 6, requerido: true),
                    _campo(_pasos, 'Pasos de preparación (uno por línea) *',
                        lineas: 8, requerido: true),
                    _campo(_contexto, 'Historia y contexto cultural', lineas: 4),
                    _campo(_informante, 'Compartida por (nombre del cocinero/a)'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _ocupado ? null : _guardar,
                      icon: const Icon(Icons.save),
                      label: Text(receta == null ? 'Guardar y continuar' : 'Guardar cambios'),
                    ),
                  ],
                ),
              ),
              if (_ocupado)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(_mensajeOcupado, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _campo(TextEditingController c, String etiqueta,
      {int lineas = 1, bool requerido = false, bool numero = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        minLines: lineas,
        maxLines: lineas == 1 ? 1 : lineas + 6,
        keyboardType: numero
            ? TextInputType.number
            : (lineas > 1 ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(labelText: etiqueta, alignLabelWithHint: lineas > 1),
        validator: requerido
            ? (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null
            : null,
      ),
    );
  }
}

class _SeccionMedia extends StatelessWidget {
  final Receta receta;
  final bool ocupado;
  final Future<void> Function({required bool video, required ImageSource fuente}) onAgregar;
  final void Function(Media) onPortada;
  final void Function(Media) onEliminar;

  const _SeccionMedia({
    required this.receta,
    required this.ocupado,
    required this.onAgregar,
    required this.onPortada,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Fotos y videos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colores.azul)),
        const SizedBox(height: 4),
        const Text('Máximo 50 MB por archivo. Se guardan en la base de datos en línea.',
            style: TextStyle(fontSize: 12, color: Colores.cafe)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _boton(Icons.photo_library, 'Foto de galería',
                () => onAgregar(video: false, fuente: ImageSource.gallery)),
            _boton(Icons.photo_camera, 'Tomar foto',
                () => onAgregar(video: false, fuente: ImageSource.camera)),
            _boton(Icons.video_library, 'Video de galería',
                () => onAgregar(video: true, fuente: ImageSource.gallery)),
            _boton(Icons.videocam, 'Grabar video',
                () => onAgregar(video: true, fuente: ImageSource.camera)),
          ],
        ),
        const SizedBox(height: 12),
        if (receta.media.isEmpty)
          const Text('Esta receta aún no tiene fotos ni videos.')
        else
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [for (final m in receta.media) _miniatura(context, m)],
          ),
      ],
    );
  }

  Widget _boton(IconData icono, String texto, VoidCallback accion) => OutlinedButton.icon(
        onPressed: ocupado ? null : accion,
        icon: Icon(icono),
        label: Text(texto),
      );

  Widget _miniatura(BuildContext context, Media m) {
    final esPortada = receta.imagenPortada == m.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => m.esVideo
                  ? ReproductorVideo(url: m.url, titulo: receta.titulo)
                  : VisorFotos(fotos: [m]),
            )),
            child: m.esVideo
                ? Container(
                    color: Colores.azul,
                    child: const Icon(Icons.play_circle, color: Colors.white, size: 40),
                  )
                : CachedNetworkImage(imageUrl: m.url, fit: BoxFit.cover),
          ),
          if (esPortada)
            const Positioned(
              left: 4,
              top: 4,
              child: Icon(Icons.star, color: Colores.amarillo),
            ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
              enabled: !ocupado,
              iconColor: Colors.white,
              onSelected: (op) => op == 'portada' ? onPortada(m) : onEliminar(m),
              itemBuilder: (_) => [
                if (!m.esVideo && !esPortada)
                  const PopupMenuItem(value: 'portada', child: Text('Usar como portada')),
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
