import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el teléfono los identificadores de las recetas favoritas.
class Favoritos extends ChangeNotifier {
  Favoritos._();
  static final Favoritos instancia = Favoritos._();

  static const _clave = 'favoritos_v1';
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  bool es(String id) => _ids.contains(id);

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_clave) ?? const []);
    notifyListeners();
  }

  Future<void> alternar(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_clave, _ids.toList());
  }
}
