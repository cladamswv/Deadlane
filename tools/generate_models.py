#!/usr/bin/env python3
"""Deterministically regenerate DEADLANE's original OBJ art assets.

Authoring helper only. Runtime/export does not depend on Python or trimesh.
"""
from pathlib import Path
import numpy as np
import trimesh
from trimesh.transformations import rotation_matrix

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'models'
OUT.mkdir(parents=True, exist_ok=True)


def xf(mesh, scale=(1,1,1), translate=(0,0,0), rotate=None):
    mesh = mesh.copy()
    mesh.apply_scale(np.array(scale, dtype=float))
    if rotate:
        angle, axis = rotate
        mesh.apply_transform(rotation_matrix(angle, axis))
    mesh.apply_translation(np.array(translate, dtype=float))
    return mesh


def ico(radius=1.0, subdivisions=2, **kw):
    return xf(trimesh.creation.icosphere(subdivisions=subdivisions, radius=radius), **kw)


def box(extents, translate=(0,0,0), rotate=None):
    return xf(trimesh.creation.box(extents=extents), translate=translate, rotate=rotate)


def cyl(radius, height, translate=(0,0,0), rotate=None, sections=16):
    return xf(trimesh.creation.cylinder(radius=radius, height=height, sections=sections), translate=translate, rotate=rotate)


def concat(parts):
    m = trimesh.util.concatenate(parts)
    m.remove_unreferenced_vertices()
    return m


def save(name, mesh):
    # Godot imports OBJ normals cleanly when Trimesh exports them.
    (OUT / name).write_text(trimesh.exchange.obj.export_obj(mesh, include_normals=True), encoding='utf-8')
    print(name, len(mesh.vertices), 'verts', len(mesh.faces), 'faces', 'bounds', mesh.bounds.tolist())


def survivor_torso():
    parts=[]
    # Chest and abdomen are rounded volumes rather than a box/capsule silhouette.
    parts += [
        ico(subdivisions=2, scale=(0.40,0.43,0.27), translate=(0,0.10,0)),
        ico(subdivisions=2, scale=(0.32,0.31,0.235), translate=(0,-0.28,0.015)),
        # clavicle / collar mass
        ico(subdivisions=2, scale=(0.36,0.14,0.25), translate=(0,0.39,-0.005)),
        # shoulder musculature / padded jacket silhouette
        ico(subdivisions=2, scale=(0.185,0.17,0.235), translate=(-0.34,0.30,0)),
        ico(subdivisions=2, scale=(0.185,0.17,0.235), translate=(0.34,0.30,0)),
        # lower hem gives jacket a layered shape
        box((0.62,0.095,0.46), translate=(0,-0.505,0.02)),
    ]
    return concat(parts)


def zombie_torso():
    parts=[]
    parts += [
        ico(subdivisions=2, scale=(0.42,0.46,0.29), translate=(-0.025,0.09,0.01)),
        ico(subdivisions=2, scale=(0.31,0.34,0.245), translate=(0.015,-0.31,0.025)),
        ico(subdivisions=2, scale=(0.19,0.17,0.24), translate=(-0.39,0.31,0.03)),
        ico(subdivisions=2, scale=(0.16,0.145,0.21), translate=(0.34,0.285,-0.005)),
        # torn, uneven lower clothing mass
        box((0.58,0.10,0.47), translate=(-0.03,-0.555,0.035), rotate=(0.035,(0,0,1))),
        # hunched upper back bulge
        ico(subdivisions=1, scale=(0.30,0.19,0.20), translate=(-0.04,0.38,0.16)),
    ]
    m=concat(parts)
    # Give the whole zombie a subtle asymmetry / collapse toward one side.
    shear=np.eye(4); shear[0,1]=-0.06
    m.apply_transform(shear)
    return m


def human_head(zombie=False):
    parts=[]
    # Cranium, cheeks and jaw as a single imported mesh. Fine face details are layered in GDScript.
    parts.append(ico(subdivisions=3, scale=(0.285,0.315,0.285), translate=(0,0.055,0.035)))
    parts.append(ico(subdivisions=2, scale=(0.255,0.205,0.245), translate=(0,-0.165,-0.015)))
    parts.append(ico(subdivisions=2, scale=(0.205,0.12,0.205), translate=(0,-0.285,-0.03)))
    parts.append(ico(subdivisions=2, scale=(0.105,0.15,0.10), translate=(-0.225,-0.085,-0.015)))
    parts.append(ico(subdivisions=2, scale=(0.105,0.15,0.10), translate=(0.225,-0.085,-0.015)))
    # Nose bridge/muzzle gives the silhouette a real face instead of a sphere.
    parts.append(ico(subdivisions=2, scale=(0.075,0.125,0.115 if not zombie else 0.13), translate=(0,-0.085,-0.235)))
    if zombie:
        # Uneven jaw mass for damaged bite silhouette.
        parts.append(ico(subdivisions=1, scale=(0.15,0.075,0.16), translate=(0.075,-0.305,-0.095)))
    return concat(parts)


def combat_boot():
    parts=[
        box((0.31,0.20,0.32), translate=(0,0.04,0.05)),
        box((0.34,0.065,0.405), translate=(0,-0.07,0.085)),
        box((0.30,0.12,0.18), translate=(0,0.13,-0.055)),
        # toe cap, rounded enough to catch highlights
        ico(subdivisions=2, scale=(0.155,0.09,0.18), translate=(0,-0.015,0.205)),
    ]
    return concat(parts)



def humanoid_limb(kind="arm", zombie=False):
    parts=[]
    if kind == "arm":
        # Origin is the shoulder pivot. Upper arm and forearm taper toward the wrist.
        parts.append(ico(subdivisions=2, scale=(0.105 if not zombie else 0.115,0.22,0.115), translate=(0,-0.18,0)))
        parts.append(ico(subdivisions=2, scale=(0.092 if not zombie else 0.105,0.22,0.10), translate=(0.012 if zombie else 0,-0.45,0.012)))
        parts.append(ico(subdivisions=1, scale=(0.112,0.10,0.115), translate=(0,-0.33,0)))
        if zombie:
            # Uneven torn sleeve stump/shoulder mass.
            parts.append(ico(subdivisions=1, scale=(0.14,0.10,0.13), translate=(-0.018,-0.035,0.01)))
    else:
        # Hip-origin leg with thigh, knee and calf volumes.
        parts.append(ico(subdivisions=2, scale=(0.135 if not zombie else 0.145,0.255,0.145), translate=(0,-0.19,0)))
        parts.append(ico(subdivisions=1, scale=(0.125,0.11,0.13), translate=(0,-0.40,0)))
        parts.append(ico(subdivisions=2, scale=(0.112 if not zombie else 0.12,0.245,0.12), translate=(0.008 if zombie else 0,-0.59,0.006)))
        if zombie:
            parts.append(ico(subdivisions=1, scale=(0.15,0.09,0.14), translate=(-0.018,-0.05,0.012)))
    return concat(parts)

def wrecked_car():
    parts=[
        # lower body, hood, trunk and cabin
        box((1.76,0.42,3.42), translate=(0,0.34,0)),
        box((1.68,0.26,1.10), translate=(0,0.62,-1.05), rotate=(-0.04,(1,0,0))),
        box((1.64,0.23,0.78), translate=(0,0.61,1.20), rotate=(0.025,(1,0,0))),
        box((1.50,0.67,1.50), translate=(0,0.88,0.10)),
        # sloped windshield/rear roof masses
        box((1.48,0.08,0.77), translate=(0,0.99,-0.66), rotate=(-0.62,(1,0,0))),
        box((1.46,0.08,0.60), translate=(0,0.96,0.82), rotate=(0.58,(1,0,0))),
        box((1.43,0.10,0.74), translate=(0,1.19,0.10)),
        # bumpers and side sills
        box((1.82,0.14,0.16), translate=(0,0.22,-1.70)),
        box((1.82,0.14,0.16), translate=(0,0.22,1.70)),
        box((0.10,0.16,2.30), translate=(-0.89,0.25,0.10)),
        box((0.10,0.16,2.30), translate=(0.89,0.25,0.10)),
    ]
    # Wheels as detailed cylinders. Y is up, so cylinder axis must rotate to X.
    for x in (-0.91,0.91):
        for z in (-1.10,1.12):
            parts.append(cyl(0.33,0.18,translate=(x,0.24,z),rotate=(np.pi/2,(0,1,0)),sections=20))
            parts.append(cyl(0.17,0.20,translate=(x,0.24,z),rotate=(np.pi/2,(0,1,0)),sections=16))
    m=concat(parts)
    # Crumpled front corner: tilt a subset is complex after concat, so whole car gets a tiny wreck cant.
    m.apply_transform(rotation_matrix(np.deg2rad(1.7),(0,0,1)))
    return m


save('survivor_torso.obj', survivor_torso())
save('zombie_torso.obj', zombie_torso())
save('survivor_head.obj', human_head(False))
save('zombie_head.obj', human_head(True))
save('combat_boot.obj', combat_boot())
save('survivor_arm.obj', humanoid_limb('arm', False))
save('survivor_leg.obj', humanoid_limb('leg', False))
save('zombie_arm.obj', humanoid_limb('arm', True))
save('zombie_leg.obj', humanoid_limb('leg', True))
save('wrecked_car.obj', wrecked_car())

# v1.4 silhouette meshes: type-specific body masses so regular zombies no longer
# look like recolors of one base model.
def runner_torso():
    return concat([
        ico(subdivisions=2, scale=(0.31,0.43,0.22), translate=(0,0.08,0)),
        ico(subdivisions=2, scale=(0.24,0.34,0.20), translate=(0,-0.30,0.02)),
        ico(subdivisions=1, scale=(0.14,0.15,0.18), translate=(-0.29,0.30,0.02)),
        ico(subdivisions=1, scale=(0.14,0.15,0.18), translate=(0.29,0.30,-0.01)),
        box((0.46,0.08,0.38), translate=(0,-0.56,0.02), rotate=(0.05,(0,0,1))),
    ])

def armored_torso():
    return concat([
        ico(subdivisions=2, scale=(0.46,0.48,0.31), translate=(0,0.07,0)),
        ico(subdivisions=2, scale=(0.34,0.34,0.27), translate=(0,-0.34,0.02)),
        box((0.82,0.68,0.36), translate=(0,0.04,-0.01)),
        box((0.74,0.15,0.40), translate=(0,0.39,0.0)),
        box((0.28,0.26,0.37), translate=(-0.42,0.28,0.0), rotate=(0.14,(0,0,1))),
        box((0.28,0.26,0.37), translate=(0.42,0.28,0.0), rotate=(-0.14,(0,0,1))),
    ])

def brute_torso():
    return concat([
        ico(subdivisions=2, scale=(0.60,0.56,0.39), translate=(0,0.09,0)),
        ico(subdivisions=2, scale=(0.43,0.40,0.32), translate=(0,-0.39,0.03)),
        ico(subdivisions=2, scale=(0.27,0.24,0.34), translate=(-0.55,0.29,0.02)),
        ico(subdivisions=2, scale=(0.27,0.24,0.34), translate=(0.55,0.29,-0.01)),
        box((0.90,0.13,0.58), translate=(0,-0.68,0.04)),
    ])

def spitter_torso():
    return concat([
        ico(subdivisions=2, scale=(0.40,0.46,0.30), translate=(0,0.06,0)),
        ico(subdivisions=2, scale=(0.36,0.38,0.32), translate=(0,-0.35,0.08)),
        ico(subdivisions=2, scale=(0.28,0.30,0.34), translate=(0,0.34,-0.02)),
        ico(subdivisions=1, scale=(0.20,0.18,0.24), translate=(-0.37,0.26,0.0)),
        ico(subdivisions=1, scale=(0.18,0.16,0.22), translate=(0.34,0.25,0.0)),
    ])

def colossus_torso():
    return concat([
        ico(subdivisions=2, scale=(0.74,0.63,0.47), translate=(0,0.10,0)),
        ico(subdivisions=2, scale=(0.54,0.46,0.39), translate=(0,-0.49,0.04)),
        box((1.30,0.82,0.38), translate=(0,0.06,0.08)),
        box((0.52,0.32,0.52), translate=(-0.65,0.34,0.02), rotate=(0.16,(0,0,1))),
        box((0.52,0.32,0.52), translate=(0.65,0.34,0.02), rotate=(-0.16,(0,0,1))),
        box((1.12,0.16,0.68), translate=(0,-0.76,0.05)),
    ])

save('zombie_runner_torso.obj', runner_torso())
save('zombie_armored_torso.obj', armored_torso())
save('zombie_brute_torso.obj', brute_torso())
save('zombie_spitter_torso.obj', spitter_torso())
save('zombie_colossus_torso.obj', colossus_torso())
