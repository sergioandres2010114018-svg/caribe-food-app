import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/admin.dart';
import 'screens/buscar.dart';
import 'screens/cultura.dart';
import 'screens/favoritos.dart';
import 'screens/inicio.dart';
import 'services/favoritos.dart';
import 'services/repositorio.dart';
import 'widgets/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Config.hayBaseDeDatos) {
    try {
      await Supabase.initialize(
        url: Config.supabaseUrl,
        anonKey: Config.supabaseAnonKey,
      );
      Repositorio.supabaseListo = true;
    } catch (e) {
      debugPrint('No se pudo iniciar Supabase: $e');
    }
  }

  await Favoritos.instancia.cargar();
  Repositorio.instancia.cargar();

  runApp(const CaribeFoodApp());
}

class CaribeFoodApp extends StatelessWidget {
  const CaribeFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaribeFood',
      debugShowCheckedModeBanner: false,
      theme: crearTema(),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indice = 0;

  static const _pantallas = [
    PantallaInicio(),
    PantallaBuscar(),
    PantallaFavoritos(),
    PantallaCultura(),
    PantallaAdmin(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Cultura'),
          NavigationDestination(icon: Icon(Icons.cloud_upload_outlined), selectedIcon: Icon(Icons.cloud_upload), label: 'Subir'),
        ],
      ),
    );
  }
}
