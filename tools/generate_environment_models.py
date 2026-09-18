#!/usr/bin/env python3
"""Generate DEADLANE v1.4 environment/weapon meshes deterministically.

These are original game assets assembled from primitive solids. Godot runtime does
not depend on Python/trimesh; generated OBJ files are committed in assets/models.
"""
from pathlib import Path
import math
import numpy as np
import trimesh
from trimesh.transformations import rotation_matrix

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "models"
OUT.mkdir(parents=True, exist_ok=True)


def xf(mesh, scale=(1,1,1), translate=(0,0,0), rotate=None):
    m = mesh.copy()
    m.apply_scale(np.array(scale, dtype=float))
    if rotate:
        angle, axis = rotate
        m.apply_transform(rotation_matrix(angle, axis))
    m.apply_translation(np.array(translate, dtype=float))
    return m


def box(extents, translate=(0,0,0), rotate=None):
    return xf(trimesh.creation.box(extents=extents), translate=translate, rotate=rotate)


def cyl(radius, height, translate=(0,0,0), rotate=None, sections=16):
    return xf(trimesh.creation.cylinder(radius=radius, height=height, sections=sections), translate=translate, rotate=rotate)


def ico(radius=1.0, subdivisions=2, scale=(1,1,1), translate=(0,0,0), rotate=None):
    return xf(trimesh.creation.icosphere(subdivisions=subdivisions, radius=radius), scale=scale, translate=translate, rotate=rotate)


def concat(parts):
    m = trimesh.util.concatenate(parts)
    m.remove_unreferenced_vertices()
    return m


def save(name, parts):
    m = concat(parts) if isinstance(parts, list) else parts
    (OUT / name).write_text(trimesh.exchange.obj.export_obj(m, include_normals=True), encoding="utf-8")
    print(f"{name}: {len(m.vertices)} verts / {len(m.faces)} faces")


def wheel(x, y, z, r=0.34, w=0.20):
    return [
        cyl(r, w, (x,y,z), (math.pi/2,(0,1,0)), 20),
        cyl(r*0.55, w*1.08, (x,y,z), (math.pi/2,(0,1,0)), 14),
    ]


def assault_rifle():
    p=[
        box((0.18,0.19,0.48),(0,0,-0.36)),
        box((0.15,0.15,0.46),(0,0,-0.78)),
        box((0.16,0.18,0.34),(0,0,-0.03),(-0.10,(1,0,0))),
        box((0.08,0.08,0.56),(0,0,-1.18)),
        cyl(0.032,0.66,(0,0,-1.55),(math.pi/2,(1,0,0)),12),
        box((0.105,0.31,0.14),(0,-0.22,-0.45),(-0.18,(1,0,0))),
        box((0.065,0.12,0.31),(0,0.14,-0.60)),
        box((0.06,0.07,0.52),(0,0.17,-0.84)),
        cyl(0.055,0.28,(0,0.22,-0.66),(math.pi/2,(1,0,0)),14),
        box((0.032,0.16,0.08),(0,0.19,-1.19)),
    ]
    for z in (-0.57,-0.69,-0.81,-0.93):
        p.append(box((0.17,0.025,0.025),(0,0.08,z)))
    return p


def smg():
    p=[
        box((0.21,0.22,0.50),(0,0,-0.38)),
        box((0.16,0.17,0.25),(0,0,-0.72)),
        cyl(0.035,0.40,(0,0,-0.96),(math.pi/2,(1,0,0)),12),
        box((0.12,0.40,0.12),(0,-0.24,-0.44),(-0.08,(1,0,0))),
        box((0.04,0.05,0.58),(0,0.08,-0.04)),
        box((0.30,0.045,0.04),(0,0.08,0.20)),
        box((0.10,0.17,0.18),(0,-0.11,-0.14)),
        cyl(0.055,0.23,(0,0.20,-0.46),(math.pi/2,(1,0,0)),12),
    ]
    return p


def shotgun():
    p=[
        box((0.18,0.19,0.46),(0,0,-0.30)),
        box((0.18,0.17,0.32),(0,0,-0.66)),
        cyl(0.045,1.02,(-0.055,0.02,-1.18),(math.pi/2,(1,0,0)),14),
        cyl(0.037,0.89,(0.06,-0.08,-1.12),(math.pi/2,(1,0,0)),12),
        box((0.21,0.18,0.36),(0,-0.035,-0.94)),
        box((0.18,0.21,0.50),(0,0,-0.02),(-0.10,(1,0,0))),
        box((0.11,0.29,0.12),(0,-0.20,-0.38),(-0.15,(1,0,0))),
    ]
    for z in np.linspace(-0.83,-1.06,5):
        p.append(box((0.215,0.035,0.025),(0,-0.04,float(z))))
    return p


def piercer():
    p=[
        box((0.15,0.18,0.60),(0,0,-0.38)),
        box((0.12,0.14,0.73),(0,0,-0.98)),
        cyl(0.030,1.05,(0,0,-1.62),(math.pi/2,(1,0,0)),12),
        box((0.08,0.11,0.65),(0,0.11,-0.72)),
        cyl(0.062,0.46,(0,0.19,-0.54),(math.pi/2,(1,0,0)),14),
        box((0.12,0.30,0.12),(0,-0.21,-0.45),(-0.10,(1,0,0))),
        box((0.18,0.10,0.34),(0,0.0,-0.06)),
        box((0.26,0.035,0.06),(0,0.10,-0.18)),
    ]
    return p


def wrecked_bus():
    p=[
        box((2.45,1.35,6.7),(0,0.85,0)),
        box((2.38,0.58,5.9),(0,1.72,0.05)),
        box((2.32,0.14,5.4),(0,2.05,0.12),(-0.025,(0,0,1))),
        box((2.42,0.22,0.28),(0,0.50,-3.36),(0.06,(0,0,1))),
        box((2.42,0.20,0.24),(0,0.52,3.38)),
        box((0.09,1.34,4.4),(-1.24,1.38,0.1)),
        box((0.09,1.34,4.4),(1.24,1.38,0.1),(0.035,(0,0,1))),
        box((2.2,0.07,1.0),(0,1.70,-3.18),(-0.28,(1,0,0))),
    ]
    for z in (-2.25, 2.25):
        p += wheel(-1.27,0.50,z,0.48,0.23) + wheel(1.27,0.50,z,0.48,0.23)
    # ribs and frame details
    for z in np.linspace(-2.5,2.6,7):
        p.append(box((2.48,0.07,0.07),(0,1.66,float(z))))
    # crumpled front and hanging door
    p += [
        box((1.05,0.35,0.75),(0.55,0.65,-3.28),(0.28,(0,1,0))),
        box((0.10,1.30,0.88),(-1.35,1.22,-1.65),(-0.32,(0,0,1))),
    ]
    return p


def ambulance_wreck():
    p=[
        box((1.92,1.28,3.40),(0,0.77,0.18)),
        box((1.78,0.76,1.32),(0,1.28,-1.18),(-0.17,(1,0,0))),
        box((1.78,0.18,2.85),(0,1.52,0.26),(-0.025,(0,0,1))),
        box((1.78,0.52,0.10),(0,1.14,-1.73),(-0.20,(1,0,0))),
        box((1.90,0.16,0.26),(0,0.42,-1.73)),
    ]
    for z in (-0.95,1.05):
        p += wheel(-0.98,0.40,z,0.34,0.20)+wheel(0.98,0.40,z,0.34,0.20)
    # damaged rear doors and roof light bar
    p += [
        box((0.82,1.02,0.07),(-0.46,0.90,1.90),(0.08,(0,1,0))),
        box((0.82,1.02,0.07),(0.46,0.90,1.90),(-0.16,(0,1,0))),
        box((1.10,0.11,0.20),(0,1.68,-0.35)),
    ]
    return p


def military_truck():
    p=[
        box((1.85,0.82,2.30),(0,0.70,-1.05)),
        box((1.78,0.78,1.06),(0,1.38,-1.48),(-0.10,(1,0,0))),
        box((2.02,0.25,3.35),(0,0.62,1.05)),
        box((2.10,0.18,3.15),(0,0.90,1.05)),
        box((0.09,0.95,3.0),(-1.02,1.30,1.05)),
        box((0.09,0.95,3.0),(1.02,1.30,1.05)),
        box((2.06,0.10,3.05),(0,1.74,1.05)),
    ]
    for z in (-1.55,0.35,1.85):
        p += wheel(-1.03,0.47,z,0.42,0.24)+wheel(1.03,0.47,z,0.42,0.24)
    return p


def quarantine_booth():
    p=[
        box((2.10,0.16,2.20),(0,0.08,0)),
        box((2.0,0.14,2.10),(0,2.25,0),(0.04,(0,0,1))),
        box((0.16,2.10,2.0),(-0.97,1.12,0)),
        box((0.16,2.10,2.0),(0.97,1.12,0),(0.02,(0,0,1))),
        box((1.78,0.52,0.13),(0,0.47,-1.03)),
        box((0.42,1.56,0.13),(-0.68,1.30,-1.03)),
        box((0.42,1.56,0.13),(0.68,1.30,-1.03)),
        box((0.50,2.0,0.11),(0.73,1.08,1.02),(0.28,(0,1,0))),
        box((0.11,2.0,1.8),(-0.93,1.15,0)),
    ]
    return p


def shipping_container():
    p=[box((2.45,1.48,4.95),(0,0.74,0))]
    for z in np.linspace(-2.25,2.25,11):
        p.append(box((2.49,1.18,0.045),(0,0.74,float(z))))
    for x in (-1.08,1.08):
        p.append(box((0.08,1.40,4.92),(x,0.74,0)))
    p += [box((2.22,1.24,0.05),(0,0.74,-2.50)), box((0.06,1.30,0.08),(0,0.74,-2.54))]
    return p


def jersey_barrier():
    p=[
        box((2.15,0.26,0.60),(0,0.13,0)),
        box((1.78,0.60,0.44),(0,0.55,0)),
        box((1.45,0.38,0.34),(0,0.98,0)),
    ]
    return p


def streetlight():
    return [
        cyl(0.08,5.0,(0,2.5,0),None,16),
        cyl(0.07,1.25,(0.55,4.87,0),(math.pi/2,(0,0,1)),14),
        box((0.56,0.12,0.32),(1.16,4.86,0)),
        box((0.38,0.04,0.24),(1.20,4.79,0.01)),
        cyl(0.16,0.10,(0,0.07,0),None,16),
    ]


def sandbag():
    p=[ico(subdivisions=2,scale=(0.37,0.16,0.19),translate=(0,0,0))]
    # seam ridges
    p += [cyl(0.015,0.62,(0,0.0,0.18),(math.pi/2,(0,1,0)),8), cyl(0.015,0.62,(0,0.0,-0.18),(math.pi/2,(0,1,0)),8)]
    return p


def rooftop_tank():
    return [
        cyl(0.78,1.55,(0,1.1,0),None,24),
        cyl(0.80,0.10,(0,1.90,0),None,24),
        cyl(0.16,0.22,(0,2.03,0),None,12),
        *[cyl(0.055,1.20,(math.cos(a)*0.63,0.52,math.sin(a)*0.63),None,10) for a in (0,math.pi/2,math.pi,3*math.pi/2)]
    ]


def billboard_frame():
    p=[
        box((4.8,0.12,0.12),(0,3.3,0)),
        box((0.12,3.3,0.12),(-2.25,1.65,0)),
        box((0.12,3.3,0.12),(2.25,1.65,0)),
        box((4.4,2.15,0.08),(0,2.25,0)),
    ]
    for x in (-1.8,-0.9,0,0.9,1.8):
        p.append(box((0.045,2.0,0.18),(x,2.25,0.04)))
    return p


def utility_transformer():
    return [
        box((1.35,1.55,0.75),(0,0.78,0)),
        box((1.22,0.12,0.82),(0,1.58,0)),
        cyl(0.10,0.34,(-0.35,1.87,0),None,12),
        cyl(0.10,0.34,(0,1.87,0),None,12),
        cyl(0.10,0.34,(0.35,1.87,0),None,12),
        box((0.08,0.45,0.09),(-0.58,0.80,0.40)),
        box((0.08,0.45,0.09),(0.58,0.80,0.40)),
    ]


def satellite_dish():
    p=[cyl(0.06,1.35,(0,0.68,0),None,12)]
    # shallow dish approximated by scaled sphere cap + feed arm
    dish=ico(subdivisions=3,scale=(0.75,0.22,0.75),translate=(0,1.55,0),rotate=(0.48,(1,0,0)))
    p.append(dish)
    p.append(cyl(0.025,0.62,(0,1.62,-0.30),(0.58,(1,0,0)),10))
    p.append(ico(subdivisions=1,scale=(0.08,0.08,0.08),translate=(0,1.88,-0.52)))
    return p


ASSETS = {
    'assault_rifle.obj': assault_rifle(),
    'smg.obj': smg(),
    'shotgun.obj': shotgun(),
    'piercer.obj': piercer(),
    'wrecked_bus.obj': wrecked_bus(),
    'ambulance_wreck.obj': ambulance_wreck(),
    'military_truck.obj': military_truck(),
    'quarantine_booth.obj': quarantine_booth(),
    'shipping_container.obj': shipping_container(),
    'jersey_barrier.obj': jersey_barrier(),
    'streetlight.obj': streetlight(),
    'sandbag.obj': sandbag(),
    'rooftop_tank.obj': rooftop_tank(),
    'billboard_frame.obj': billboard_frame(),
    'utility_transformer.obj': utility_transformer(),
    'satellite_dish.obj': satellite_dish(),
}

for name, parts in ASSETS.items():
    save(name, parts)

# Additional peripheral silhouettes for v1.4.
def helicopter_wreck():
    p=[
        ico(subdivisions=2,scale=(0.72,0.48,1.20),translate=(0,0.65,0)),
        ico(subdivisions=2,scale=(0.58,0.38,0.62),translate=(0,0.70,-0.92)),
        box((0.34,0.26,2.9),(0,0.72,1.55),(0.08,(0,1,0))),
        box((0.12,1.15,0.85),(0,1.10,2.90),(0.05,(1,0,0))),
        cyl(0.06,4.8,(0,1.45,0),(math.pi/2,(0,0,1)),12),
        cyl(0.055,4.5,(0,1.45,0),(math.pi/2,(1,0,0)),12),
        box((0.10,0.10,1.55),(-0.62,0.12,0.22),(-0.18,(0,0,1))),
        box((0.10,0.10,1.55),(0.62,0.12,0.22),(0.18,(0,0,1))),
    ]
    return p

def crane_tower():
    p=[]
    h=8.0
    for x in (-0.60,0.60):
        for z in (-0.60,0.60):
            p.append(box((0.10,h,0.10),(x,h/2,z)))
    for y in np.arange(0.5,h,0.7):
        p += [
            box((1.75,0.07,0.07),(0,float(y),-0.60),(0.55,(0,0,1))),
            box((1.75,0.07,0.07),(0,float(y),0.60),(-0.55,(0,0,1))),
            box((0.07,0.07,1.75),(-0.60,float(y),0),(0.55,(1,0,0))),
            box((0.07,0.07,1.75),(0.60,float(y),0),(-0.55,(1,0,0))),
        ]
    p += [
        box((8.0,0.12,0.12),(3.4,h,0.0)),
        box((2.2,0.12,0.12),(-1.5,h,0.0)),
        box((0.10,1.0,0.10),(6.9,h-0.5,0.0)),
        box((1.35,0.85,1.2),(0.2,h-0.45,0.0)),
    ]
    return p

save('helicopter_wreck.obj', helicopter_wreck())
save('crane_tower.obj', crane_tower())
