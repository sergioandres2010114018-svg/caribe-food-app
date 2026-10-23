-- =====================================================================
-- CaribeFood App — Base de datos en Supabase
-- Pega TODO este archivo en Supabase > SQL Editor > New query > Run
-- =====================================================================

-- 1) CATEGORÍAS --------------------------------------------------------
create table if not exists public.categorias (
  id      text primary key,          -- ej: 'pescados'
  nombre  text not null,
  icono   text not null default 'restaurant',
  orden   int  not null default 0
);

-- 2) RECETAS -----------------------------------------------------------
create table if not exists public.recetas (
  id               text primary key,                       -- ej: 'arroz-con-coco'
  titulo           text not null,
  categoria        text not null references public.categorias(id),
  region           text,
  descripcion      text,
  tiempo_min       int  default 30,
  porciones        int  default 4,
  dificultad       text default 'Fácil',
  ingredientes     text[] not null default '{}',
  pasos            text[] not null default '{}',
  contexto         text,                                   -- historia / contexto cultural
  informante       text,                                   -- quién compartió la receta
  imagen_portada   text,                                   -- URL pública de la foto principal
  publicada        boolean not null default true,
  creado_en        timestamptz not null default now()
);

-- 3) FOTOS Y VIDEOS DE CADA RECETA ---------------------------------------
create table if not exists public.receta_media (
  id         uuid primary key default gen_random_uuid(),
  receta_id  text not null references public.recetas(id) on delete cascade,
  tipo       text not null check (tipo in ('imagen','video')),
  url        text not null,        -- URL pública del archivo
  ruta       text not null,        -- ruta dentro del bucket (para borrarlo)
  descripcion text,
  orden      int not null default 0,
  creado_en  timestamptz not null default now()
);
create index if not exists receta_media_receta_idx on public.receta_media(receta_id);

-- 4) SEGURIDAD (Row Level Security) -------------------------------------
-- Cualquiera puede VER. Solo usuarios con sesión iniciada (el equipo) pueden
-- crear, editar o borrar.
alter table public.categorias   enable row level security;
alter table public.recetas      enable row level security;
alter table public.receta_media enable row level security;

drop policy if exists "leer categorias" on public.categorias;
create policy "leer categorias" on public.categorias for select using (true);
drop policy if exists "equipo edita categorias" on public.categorias;
create policy "equipo edita categorias" on public.categorias for all
  to authenticated using (true) with check (true);

drop policy if exists "leer recetas" on public.recetas;
create policy "leer recetas" on public.recetas for select using (publicada = true or auth.role() = 'authenticated');
drop policy if exists "equipo edita recetas" on public.recetas;
create policy "equipo edita recetas" on public.recetas for all
  to authenticated using (true) with check (true);

drop policy if exists "leer media" on public.receta_media;
create policy "leer media" on public.receta_media for select using (true);
drop policy if exists "equipo edita media" on public.receta_media;
create policy "equipo edita media" on public.receta_media for all
  to authenticated using (true) with check (true);

-- 5) ALMACENAMIENTO DE FOTOS Y VIDEOS (Storage) -------------------------
-- Bucket público "recetas-media". Límite 50 MB por archivo (máximo del plan gratis).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('recetas-media', 'recetas-media', true, 52428800,
        array['image/jpeg','image/png','image/webp','video/mp4','video/quicktime','video/3gpp'])
on conflict (id) do update set public = true,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "ver archivos recetas" on storage.objects;
create policy "ver archivos recetas" on storage.objects for select
  using (bucket_id = 'recetas-media');

drop policy if exists "equipo sube archivos" on storage.objects;
create policy "equipo sube archivos" on storage.objects for insert
  to authenticated with check (bucket_id = 'recetas-media');

drop policy if exists "equipo actualiza archivos" on storage.objects;
create policy "equipo actualiza archivos" on storage.objects for update
  to authenticated using (bucket_id = 'recetas-media');

drop policy if exists "equipo borra archivos" on storage.objects;
create policy "equipo borra archivos" on storage.objects for delete
  to authenticated using (bucket_id = 'recetas-media');
