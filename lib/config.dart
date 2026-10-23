/// Configuración de conexión a la base de datos (Supabase).
///
/// Los valores llegan al compilar el APK desde los "Secrets" de GitHub
/// (SUPABASE_URL y SUPABASE_ANON_KEY). Si están vacíos, la app funciona
/// igual con el catálogo de recetas que viene incluido, sin conexión.
///
/// Si compilas desde tu computador puedes usar:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
class Config {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Nombre del "bucket" donde se guardan fotos y videos.
  static const bucketMedia = 'recetas-media';

  /// Límite del plan gratuito de Supabase: 50 MB por archivo.
  static const maxBytesArchivo = 50 * 1024 * 1024;

  static bool get hayBaseDeDatos =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
