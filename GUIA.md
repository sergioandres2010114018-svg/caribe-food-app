# Guía paso a paso — CaribeFood App

Esta guía lleva el proyecto desde tu computador hasta un **APK instalable**, con una
**base de datos en línea** que guarda las recetas, **fotos y videos**. Todo con planes gratuitos.

| Pieza | Herramienta | Costo |
|---|---|---|
| Código y control de versiones | GitHub | Gratis |
| Compilar el APK | GitHub Actions (automático) | Gratis |
| Base de datos + fotos y videos | Supabase (PostgreSQL + Storage) | Gratis (500 MB datos, 1 GB archivos, 50 MB por archivo) |
| App | Flutter / Dart | Gratis |

> **¿Por qué Supabase y no Firebase?** Desde febrero de 2026, el almacenamiento de archivos
> de Firebase (Cloud Storage) exige activar el plan de pago Blaze con tarjeta, aunque no se
> consuma nada. Supabase ofrece base de datos y almacenamiento de fotos/videos gratis sin tarjeta.

---

## Parte 1 — Crear la base de datos (Supabase) · 10 minutos

1. Entra a **https://supabase.com** → *Start your project* → regístrate con tu cuenta de GitHub.
2. *New project*:
   - Nombre: `caribefood`
   - Contraseña de la base de datos: inventa una y **guárdala**.
   - Región: la más cercana (por ejemplo *East US*).
3. Espera 1–2 minutos a que el proyecto quede listo.
4. Menú izquierdo → **SQL Editor** → *New query*:
   - Abre el archivo `supabase/1_esquema.sql`, copia todo, pégalo y pulsa **Run**.
   - Haz otra *New query* con `supabase/2_datos_iniciales.sql` y pulsa **Run**.
   - Esto crea las tablas `categorias`, `recetas`, `receta_media` y el espacio
     **recetas-media** donde se guardan las fotos y videos.
5. Crear las cuentas del equipo (solo ellos podrán subir contenido):
   **Authentication → Users → Add user → Create new user**.
   Escribe correo y contraseña de cada aprendiz y marca **Auto Confirm User**.
6. **Seguridad (importante):** **Authentication → Sign In / Providers** → desactiva
   *Allow new users to sign up*. Así nadie de afuera puede crear cuentas.
7. Copia tus llaves: **Project Settings → API** (o *Data API* / *API Keys*):
   - **Project URL** → algo como `https://abcdxyz.supabase.co`
   - **anon public key** (o *publishable key*, empieza por `sb_publishable_…` o `eyJ…`)

   ⚠️ Usa solo la llave *anon / publishable*. **Nunca** pongas la llave `service_role` / `secret` en la app.

---

## Parte 2 — Subir el proyecto a GitHub · 10 minutos

1. Entra a **https://github.com** → **New repository**.
   - Nombre: `caribe-food-app`
   - Público (recomendado; las compilaciones son ilimitadas) → *Create repository*.
2. Descomprime `caribe_food_app.zip` en tu computador.
3. En la página del repositorio: **uploading an existing file** (o *Add file → Upload files*).
   Arrastra **todo el contenido** de la carpeta `caribe_food_app` (no la carpeta en sí) → *Commit changes*.
4. **Revisa que exista `.github/workflows/apk.yml`** en el repositorio.
   Las carpetas que empiezan con punto a veces están ocultas en Windows/Mac y no se suben. Si no aparece:
   *Add file → Create new file* → en el nombre escribe `.github/workflows/apk.yml` →
   pega el contenido de ese archivo → *Commit changes*.

> Alternativa con Git (si lo tienen instalado):
> ```bash
> cd caribe_food_app
> git init && git add . && git commit -m "CaribeFood App v1"
> git branch -M main
> git remote add origin https://github.com/TU_USUARIO/caribe-food-app.git
> git push -u origin main
> ```

---

## Parte 3 — Conectar GitHub con la base de datos · 3 minutos

En el repositorio: **Settings → Secrets and variables → Actions → New repository secret**.
Crea estos dos:

| Name | Secret |
|---|---|
| `SUPABASE_URL` | la Project URL de Supabase |
| `SUPABASE_ANON_KEY` | la llave anon / publishable |

---

## Parte 4 — Obtener el APK · 10 minutos (automático)

1. Pestaña **Actions** → si pide activarlas, pulsa *I understand… enable them*.
2. Elige **Generar APK** → **Run workflow** → *Run workflow*.
3. Espera el ✅ verde (8–12 minutos la primera vez).
4. Ve a la pestaña **Releases** (lado derecho de la página principal del repositorio) →
   descarga **CaribeFood.apk**. También queda en *Actions → la ejecución → Artifacts*.

Cada vez que suban un cambio a `main`, GitHub genera un APK nuevo solo.

### Instalar en el celular
1. Abre el enlace de *Releases* desde el celular y descarga `CaribeFood.apk`.
2. Ábrelo. Android pedirá permitir **instalar apps de origen desconocido** → acepta.
3. Si Play Protect avisa, toca *Instalar de todas formas* (es normal en apps que no están en la Play Store).

---

## Parte 5 — Subir recetas, fotos y videos desde la app

1. Abre la app → pestaña **Subir** → inicia sesión con un usuario creado en la Parte 1.
2. **Nueva receta** → llena el formulario → **Guardar y continuar**.
3. Aparecen los botones: *Foto de galería*, *Tomar foto*, *Video de galería*, *Grabar video*.
4. La primera foto se usa como portada. En cada miniatura (⋮) puedes cambiar la portada o eliminar.
5. Todos los celulares con la app verán el contenido nuevo al deslizar hacia abajo en Inicio.

**Consejos de espacio (plan gratis 1 GB):** graba videos cortos (30 s a 2 min) en calidad 720p.
Las fotos se reducen solas a 1600 px. Máximo 50 MB por archivo.

---

## Cómo funciona por dentro

```
 Celular (Flutter)                      Supabase (en línea)
 ┌─────────────────────┐   lee     ┌──────────────────────────────┐
 │ Inicio · Buscar     │◄──────────│ Tabla categorias             │
 │ Favoritos · Cultura │           │ Tabla recetas                │
 │ Detalle (fotos/vid.)│           │ Tabla receta_media ──► URL   │
 │ Subir (equipo)      │──────────►│ Storage: recetas-media/      │
 └─────────────────────┘  sube     │   arroz-con-coco/123.jpg     │
     │ copia sin conexión          │   arroz-con-coco/456.mp4     │
     ▼                             └──────────────────────────────┘
 Teléfono (shared_preferences)
```

- **Sin internet:** la app muestra la última copia descargada; si nunca se conectó,
  muestra las 12 recetas incluidas en `assets/data/recetas.json`.
- **Favoritos:** se guardan en el teléfono.
- **Seguridad:** cualquiera puede *ver*; solo usuarios con sesión pueden *crear, editar o borrar*
  (reglas RLS en `supabase/1_esquema.sql`).

## Estructura del proyecto

```
lib/
  main.dart                 Arranque y menú inferior
  config.dart               Conexión a Supabase (llega desde los Secrets)
  models/receta.dart        Categoria, Receta, Media
  services/repositorio.dart Leer/guardar recetas, subir fotos y videos
  services/favoritos.dart   Favoritos en el teléfono
  screens/                  inicio, categoria, buscar, detalle, visor (fotos/video),
                            favoritos, cultura, admin (subir contenido)
  widgets/                  tema (colores corporativos), tarjetas e imágenes
assets/data/recetas.json    Catálogo incluido (12 recetas de referencia)
supabase/*.sql              Base de datos
.github/workflows/apk.yml   Compilación automática del APK
tools/                      Scripts para regenerar ícono y datos iniciales
```

## Trabajar desde el computador (opcional)

Con Flutter y Android Studio instalados:
```bash
flutter create --platforms=android --org co.edu.pijino --project-name caribe_food .
flutter pub get
dart run flutter_launcher_icons
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
```

## Problemas comunes

| Problema | Solución |
|---|---|
| La pestaña *Subir* dice “se compiló sin conexión” | Faltan los Secrets (Parte 3). Agrégalos y vuelve a ejecutar *Run workflow*. |
| “No se pudo iniciar sesión” | Revisa el usuario en Supabase → Authentication → Users y que esté confirmado. |
| La app dejó de cargar recetas nuevas | Los proyectos gratis de Supabase se **pausan tras 7 días sin uso**. Entra al panel y pulsa *Restore/Resume*. |
| Error al subir un video | Pesa más de 50 MB. Graba más corto o en menor calidad. |
| La compilación en Actions falla (❌) | Abre la ejecución, mira el paso en rojo y copia el error para revisarlo. |

## Importante sobre las recetas
Las 12 recetas incluidas son **de referencia**, escritas a partir de preparaciones conocidas
del Caribe colombiano. Según el objetivo específico 1 del proyecto, deben **validarse con
familias y cocineros de Pijiño del Carmen**: editen cantidades, pasos y el campo
*“Compartida por”* con el nombre de quien aporta cada receta.
