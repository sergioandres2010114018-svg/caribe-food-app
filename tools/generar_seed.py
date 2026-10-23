"""Genera supabase/2_datos_iniciales.sql a partir de assets/data/recetas.json.
Uso: python3 tools/generar_seed.py
"""
import json
from pathlib import Path

raiz = Path(__file__).resolve().parent.parent
datos = json.loads((raiz / "assets/data/recetas.json").read_text(encoding="utf-8"))


def q(v):
    if v is None:
        return "null"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def arr(lista):
    return "array[" + ", ".join(q(x) for x in lista) + "]::text[]" if lista else "'{}'::text[]"


lineas = ["-- Datos iniciales de CaribeFood App (generado automáticamente)",
          "-- Pega este archivo en Supabase > SQL Editor DESPUÉS de 1_esquema.sql", ""]
for c in datos["categorias"]:
    lineas.append(
        f"insert into public.categorias (id, nombre, icono, orden) values "
        f"({q(c['id'])}, {q(c['nombre'])}, {q(c['icono'])}, {c['orden']}) "
        f"on conflict (id) do update set nombre = excluded.nombre, icono = excluded.icono, orden = excluded.orden;")
lineas.append("")
for r in datos["recetas"]:
    lineas.append(
        "insert into public.recetas (id, titulo, categoria, region, descripcion, tiempo_min, porciones, "
        "dificultad, ingredientes, pasos, contexto, informante) values ("
        f"{q(r['id'])}, {q(r['titulo'])}, {q(r['categoria'])}, {q(r['region'])}, {q(r['descripcion'])}, "
        f"{r['tiempo_min']}, {r['porciones']}, {q(r['dificultad'])}, {arr(r['ingredientes'])}, "
        f"{arr(r['pasos'])}, {q(r['contexto'])}, {q(r['informante'])}) on conflict (id) do nothing;")

(raiz / "supabase/2_datos_iniciales.sql").write_text("\n".join(lineas) + "\n", encoding="utf-8")
print("OK:", len(datos["categorias"]), "categorías,", len(datos["recetas"]), "recetas")
