import 'package:flutter/material.dart';

/// Colores de la identidad corporativa de CaribeFood App.
class Colores {
  static const azul = Color(0xFF0E3B5C); // confianza, tecnología, mar profundo
  static const turquesa = Color(0xFF1BA6A6); // mar Caribe
  static const naranja = Color(0xFFF28C28); // sol, calidez
  static const amarillo = Color(0xFFF6C443); // alegría
  static const rojo = Color(0xFFD64933); // sazón
  static const verde = Color(0xFF3D8B37); // naturaleza
  static const cafe = Color(0xFF7A4B2A); // fogón, tradición
  static const crema = Color(0xFFFFF8EC);
}

ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.azul,
    primary: Colores.azul,
    secondary: Colores.naranja,
    tertiary: Colores.turquesa,
    surface: Colores.crema,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.crema,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colores.azul,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Colores.amarillo.withValues(alpha: 0.6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

IconData iconoCategoria(String nombre) {
  switch (nombre) {
    case 'set_meal':
      return Icons.set_meal;
    case 'rice_bowl':
      return Icons.rice_bowl;
    case 'soup_kitchen':
      return Icons.soup_kitchen;
    case 'bakery_dining':
      return Icons.bakery_dining;
    case 'cake':
      return Icons.cake;
    case 'local_drink':
      return Icons.local_drink;
    case 'egg':
      return Icons.egg_alt;
    case 'eco':
      return Icons.eco;
    default:
      return Icons.restaurant;
  }
}

const _paleta = [
  Colores.turquesa,
  Colores.naranja,
  Colores.rojo,
  Colores.verde,
  Colores.cafe,
  Colores.azul,
];

Color colorCategoria(String id) {
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return _paleta[h % _paleta.length];
}
