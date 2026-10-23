import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/receta.dart';

/// Fotos en pantalla completa, con zoom y deslizamiento.
class VisorFotos extends StatelessWidget {
  final List<Media> fotos;
  final int inicial;
  const VisorFotos({super.key, required this.fotos, this.inicial = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: inicial),
        itemCount: fotos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 4,
          child: Center(
            child: CachedNetworkImage(imageUrl: fotos[i].url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// Reproductor de los videos de preparación guardados en la base de datos.
class ReproductorVideo extends StatefulWidget {
  final String url;
  final String titulo;
  const ReproductorVideo({super.key, required this.url, required this.titulo});

  @override
  State<ReproductorVideo> createState() => _ReproductorVideoState();
}

class _ReproductorVideoState extends State<ReproductorVideo> {
  late final VideoPlayerController _control;
  String? _error;

  @override
  void initState() {
    super.initState();
    _control = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _control.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _control.play();
    }).catchError((Object e) {
      if (mounted) setState(() => _error = 'No se pudo cargar el video. Revisa tu conexión.');
    });
    _control.addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _control.removeListener(_actualizar);
    _control.dispose();
    super.dispose();
  }

  String _formato(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final listo = _control.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.titulo),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white))
            : !listo
                ? const CircularProgressIndicator(color: Colors.white)
                : GestureDetector(
                    onTap: () => _control.value.isPlaying ? _control.pause() : _control.play(),
                    child: AspectRatio(
                      aspectRatio: _control.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_control),
                          if (!_control.value.isPlaying)
                            const CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.play_arrow, size: 40, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: listo
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(_formato(_control.value.position),
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VideoProgressIndicator(
                        _control,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_formato(_control.value.duration),
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
