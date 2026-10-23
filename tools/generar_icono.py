"""Dibuja el ícono de CaribeFood: atardecer caribeño, mar, palmera y caldero.
Genera assets/images/icono.png (completo) e icono_frente.png (adaptativo, fondo transparente).
"""
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

S = 1024
raiz = Path(__file__).resolve().parent.parent / "assets/images"
raiz.mkdir(parents=True, exist_ok=True)

AZUL = (14, 59, 92)
TURQ = (27, 166, 166)
NARANJA = (242, 140, 40)
AMARILLO = (246, 196, 67)
ROJO = (214, 73, 51)
VERDE = (61, 139, 55)
CAFE = (122, 75, 42)


def escena(con_fondo=True):
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if con_fondo:
        # Cielo degradado
        for y in range(S):
            t = y / S
            if t < 0.6:
                k = t / 0.6
                c = tuple(int(AZUL[i] * (1 - k) + NARANJA[i] * k) for i in range(3))
            else:
                c = NARANJA
            d.line([(0, y), (S, y)], fill=c + (255,))
        # Sol
        d.ellipse([S*0.30, S*0.30, S*0.70, S*0.70], fill=AMARILLO + (255,))
        # Mar
        d.rectangle([0, S*0.60, S, S], fill=TURQ + (255,))
        for k in range(4):
            y = S*0.64 + k*38
            d.arc([S*0.1, y, S*0.45, y+40], 200, 340, fill=(255, 255, 255, 140), width=8)
            d.arc([S*0.55, y+15, S*0.9, y+55], 200, 340, fill=(255, 255, 255, 140), width=8)
    escala = 1.0 if con_fondo else 0.72
    cx, cy = S/2, S/2

    def P(x, y):
        return (cx + (x - S/2)*escala, cy + (y - S/2)*escala)

    # Palmera (tronco curvo)
    pts = [P(250 + 40*math.sin(t/20), 700 - t*12) for t in range(40)]
    d.line(pts, fill=CAFE + (255,), width=int(34*escala), joint="curve")
    top = pts[-1]
    for ang in (200, 235, 270, 305, 340, 20):
        a = math.radians(ang)
        hoja = [top]
        for k in range(1, 12):
            r = k * 22 * escala
            caida = (k ** 1.8) * 1.6 * escala
            hoja.append((top[0] + r*math.cos(a), top[1] + r*math.sin(a) + caida))
        d.line(hoja, fill=VERDE + (255,), width=int(30*escala), joint="curve")
    d.ellipse([top[0]-26*escala, top[1]-6*escala, top[0]+10*escala, top[1]+30*escala], fill=CAFE + (255,))

    # Caldero
    x0, y0, x1, y1 = *P(430, 600), *P(840, 860)
    d.chord([x0, y0 - (y1-y0)*0.5, x1, y1], 0, 180, fill=(40, 40, 45, 255))
    d.rounded_rectangle([x0-14*escala, y0-18*escala, x1+14*escala, y0+18*escala],
                        radius=int(16*escala), fill=(60, 60, 68, 255))
    # Asas
    d.ellipse([x0-50*escala, y0+10*escala, x0+5*escala, y0+60*escala], outline=(40, 40, 45, 255), width=int(14*escala))
    d.ellipse([x1-5*escala, y0+10*escala, x1+50*escala, y0+60*escala], outline=(40, 40, 45, 255), width=int(14*escala))
    # Comida: arroz y pescado
    d.chord([x0+20*escala, y0-70*escala, x1-20*escala, y0+40*escala], 180, 360, fill=(250, 240, 215, 255))
    fx, fy = P(640, 545)
    d.ellipse([fx-110*escala, fy-38*escala, fx+80*escala, fy+38*escala], fill=ROJO + (255,))
    d.polygon([P(720, 545), P(790, 495), P(790, 595)], fill=ROJO + (255,))
    d.ellipse([fx-80*escala, fy-14*escala, fx-58*escala, fy+8*escala], fill=(255, 255, 255, 255))
    # Vapor
    for k, xx in enumerate((540, 640, 740)):
        base = P(xx, 470)
        pts = [(base[0] + 14*escala*math.sin(t/3 + k), base[1] - t*7*escala) for t in range(18)]
        d.line(pts, fill=(255, 255, 255, 200), width=int(10*escala), joint="curve")
    return img


completo = escena(True)
# esquinas redondeadas para usar dentro de la app
mascara = Image.new("L", (S, S), 0)
ImageDraw.Draw(mascara).rounded_rectangle([0, 0, S, S], radius=200, fill=255)
redondo = Image.new("RGBA", (S, S), (0, 0, 0, 0))
redondo.paste(completo, (0, 0), mascara)
completo.convert("RGB").save(raiz / "icono.png")
escena(False).save(raiz / "icono_frente.png")
redondo.resize((512, 512), Image.LANCZOS).save(raiz / "logo.png")
print("Íconos generados en", raiz)
