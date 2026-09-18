#!/usr/bin/env python3
"""Generate DEADLANE v1.5 visual-upgrade assets deterministically.

Original assets only. Runtime does not depend on Python/trimesh/Pillow.
"""
from pathlib import Path
import math
import numpy as np
import trimesh
from trimesh.transformations import rotation_matrix
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
MODEL_OUT = ROOT / "assets" / "models"
TEX_OUT = ROOT / "assets" / "textures"
MODEL_OUT.mkdir(parents=True, exist_ok=True)
TEX_OUT.mkdir(parents=True, exist_ok=True)
RNG = np.random.default_rng(150915)


def xf(mesh, scale=(1,1,1), translate=(0,0,0), rotate=None):
    m = mesh.copy()
    m.apply_scale(np.asarray(scale, dtype=float))
    if rotate:
        angle, axis = rotate
        m.apply_transform(rotation_matrix(angle, axis))
    m.apply_translation(np.asarray(translate, dtype=float))
    return m


def box(extents, translate=(0,0,0), rotate=None):
    return xf(trimesh.creation.box(extents=extents), translate=translate, rotate=rotate)


def cyl(radius, height, translate=(0,0,0), rotate=None, sections=18):
    return xf(trimesh.creation.cylinder(radius=radius, height=height, sections=sections), translate=translate, rotate=rotate)


def ico(scale=(1,1,1), translate=(0,0,0), subdivisions=2, rotate=None):
    return xf(trimesh.creation.icosphere(subdivisions=subdivisions, radius=1.0), scale=scale, translate=translate, rotate=rotate)


def torus(major, minor, translate=(0,0,0), rotate=None):
    # trimesh API differs across versions; build torus parametrically for determinism.
    u = np.linspace(0, 2*math.pi, 25, endpoint=False)
    v = np.linspace(0, 2*math.pi, 11, endpoint=False)
    verts=[]; faces=[]
    for i,a in enumerate(u):
        for j,b in enumerate(v):
            verts.append(((major+minor*math.cos(b))*math.cos(a), minor*math.sin(b), (major+minor*math.cos(b))*math.sin(a)))
    nv=len(v)
    for i in range(len(u)):
        ni=(i+1)%len(u)
        for j in range(nv):
            nj=(j+1)%nv
            a=i*nv+j; b=ni*nv+j; c=ni*nv+nj; d=i*nv+nj
            faces += [(a,b,c),(a,c,d)]
    m=trimesh.Trimesh(vertices=np.asarray(verts), faces=np.asarray(faces), process=True)
    if rotate:
        m.apply_transform(rotation_matrix(rotate[0], rotate[1]))
    m.apply_translation(np.asarray(translate,float))
    return m


def concat(parts):
    m=trimesh.util.concatenate(parts)
    m.remove_unreferenced_vertices()
    return m


def save(name, parts):
    m=concat(parts) if isinstance(parts,list) else parts
    text=trimesh.exchange.obj.export_obj(m, include_normals=True)
    (MODEL_OUT/name).write_text(text, encoding='utf-8')
    print(f"{name}: {len(m.vertices)} verts / {len(m.faces)} faces")


def survivor_backpack():
    p=[
        box((0.57,0.76,0.26),(0,0,0)),
        box((0.48,0.16,0.30),(0,0.39,0.0)),
        box((0.44,0.22,0.22),(0,-0.39,0.02)),
        box((0.18,0.34,0.12),(-0.35,-0.02,0.02),(-0.10,(0,0,1))),
        box((0.18,0.34,0.12),(0.35,-0.02,0.02),(0.10,(0,0,1))),
        cyl(0.105,0.58,(0,-0.33,0.17),(math.pi/2,(0,0,1)),16),
        box((0.075,0.84,0.055),(-0.24,0.0,-0.15),(0.08,(0,0,1))),
        box((0.075,0.84,0.055),(0.24,0.0,-0.15),(-0.08,(0,0,1))),
        box((0.32,0.08,0.08),(0,0.20,-0.17)),
    ]
    # buckles / MOLLE rows
    for y in (-0.20, 0.0, 0.20):
        for x in (-0.18, 0.0, 0.18):
            p.append(box((0.12,0.035,0.035),(x,y,0.15)))
    return p


def tactical_glove(zombie=False):
    p=[ico((0.115,0.105,0.10),(0,0,0),2)]
    lengths=[0.17,0.19,0.20,0.18]
    for i,L in enumerate(lengths):
        x=-0.09+i*0.06
        p.append(cyl(0.022 if not zombie else 0.025,L,(x,-0.11,0.0),(0.10*(i-1.5),(0,0,1)),10))
    p.append(cyl(0.028,0.13,(0.105,-0.055,0.02),(-0.65,(0,0,1)),10))
    if zombie:
        # Broken fingertip / asymmetry.
        p.append(ico((0.04,0.025,0.03),(-0.085,-0.21,0.01),1))
    return p


def zombie_jaw():
    p=[
        ico((0.22,0.10,0.17),(0,0,0),2),
        box((0.32,0.06,0.10),(0,0.055,0.08),(-0.04,(1,0,0))),
    ]
    for i,x in enumerate(np.linspace(-0.13,0.13,6)):
        p.append(cyl(0.015,0.075,(float(x),0.10,0.14),(0.10*((i%2)*2-1),(0,0,1)),8))
    return p


def wheel(x,y,z,r=0.38,w=0.22):
    return [
        torus(r*0.73,r*0.24,(x,y,z),(math.pi/2,(0,0,1))),
        cyl(r*0.47,w*1.05,(x,y,z),(math.pi/2,(0,0,1)),18),
    ]


def police_suv_wreck():
    p=[
        box((1.95,0.46,3.55),(0,0.48,0)),
        box((1.82,0.65,1.72),(0,1.00,0.28)),
        box((1.78,0.12,1.52),(0,1.39,0.35),(-0.03,(0,0,1))),
        box((1.75,0.10,0.86),(0,1.05,-0.83),(-0.66,(1,0,0))),
        box((1.72,0.09,0.67),(0,1.03,1.06),(0.62,(1,0,0))),
        box((1.98,0.16,0.18),(0,0.25,-1.82)),
        box((2.10,0.09,0.10),(0,0.42,-1.93)),
        box((0.10,0.64,0.10),(-0.86,0.63,-1.83),(0.25,(0,0,1))),
        box((0.10,0.64,0.10),(0.86,0.63,-1.83),(-0.25,(0,0,1))),
        box((1.14,0.12,0.16),(0,1.55,0.04)),
        box((0.12,0.16,0.22),(-0.42,1.55,0.04)),
        box((0.12,0.16,0.22),(0.42,1.55,0.04)),
        # torn door hanging out
        box((0.07,0.72,1.22),(1.08,0.85,0.35),(0.34,(0,1,0))),
    ]
    for z in (-1.08,1.10):
        p += wheel(-1.02,0.31,z)+wheel(1.02,0.31,z)
    return p


def fire_engine_wreck():
    p=[
        box((2.25,0.60,5.05),(0,0.63,0.35)),
        box((2.18,1.10,1.65),(0,1.36,-1.63),(-0.05,(1,0,0))),
        box((2.14,1.12,2.85),(0,1.36,1.17)),
        box((2.12,0.10,2.76),(0,1.95,1.17)),
        box((2.20,0.18,0.24),(0,0.38,-2.46),(0.10,(0,0,1))),
        box((0.12,0.22,2.65),(-1.11,1.25,1.25)),
        box((0.12,0.22,2.65),(1.11,1.25,1.25)),
        # roof ladder
        box((0.10,0.10,3.95),(-0.42,2.05,0.38),(0.02,(0,1,0))),
        box((0.10,0.10,3.95),(0.42,2.05,0.38),(-0.02,(0,1,0))),
    ]
    for z in np.linspace(-1.2,1.95,7):
        p.append(box((0.96,0.055,0.055),(0,2.05,float(z))))
    for z in (-1.55,0.48,1.92):
        p += wheel(-1.14,0.34,z,0.42,0.24)+wheel(1.14,0.34,z,0.42,0.24)
    # bent hose reel
    p += [torus(0.38,0.045,(1.13,1.25,0.90),(math.pi/2,(0,1,0))), cyl(0.04,0.65,(1.17,0.93,1.16),(0.32,(1,0,0)),12)]
    return p


def rubble_chunk():
    p=[]
    for i in range(14):
        x=RNG.uniform(-0.7,0.7); z=RNG.uniform(-0.55,0.55); y=RNG.uniform(0.02,0.24)
        sx=RNG.uniform(0.16,0.48); sy=RNG.uniform(0.10,0.32); sz=RNG.uniform(0.16,0.52)
        p.append(box((sx,sy,sz),(x,y,z),(RNG.uniform(-.5,.5),(RNG.uniform(-1,1),1,RNG.uniform(-1,1)))))
    for i in range(4):
        p.append(cyl(0.025,RNG.uniform(0.6,1.3),(RNG.uniform(-0.5,0.5),0.35,RNG.uniform(-0.4,0.4)),(RNG.uniform(-.8,.8),(1,0,RNG.uniform(-1,1))),8))
    return p


save('survivor_backpack_v15.obj', survivor_backpack())
save('survivor_glove_v15.obj', tactical_glove(False))
save('zombie_hand_v15.obj', tactical_glove(True))
save('zombie_jaw_v15.obj', zombie_jaw())
save('police_suv_wreck_v15.obj', police_suv_wreck())
save('fire_engine_wreck_v15.obj', fire_engine_wreck())
save('rubble_chunk_v15.obj', rubble_chunk())

# Transparent road decals. These use plain UVs on a Godot QuadMesh.
def radial_alpha(size, center, rx, ry, angle=0.0):
    y,x=np.mgrid[0:size,0:size]
    cx,cy=center
    ca,sa=math.cos(angle),math.sin(angle)
    X=(x-cx)*ca+(y-cy)*sa
    Y=-(x-cx)*sa+(y-cy)*ca
    return np.exp(-((X/rx)**2+(Y/ry)**2)*2.0)

S=512
# Oil / grime stain
alpha=np.zeros((S,S),float)
for _ in range(18):
    alpha=np.maximum(alpha, radial_alpha(S,(RNG.uniform(120,392),RNG.uniform(120,392)),RNG.uniform(35,100),RNG.uniform(25,75),RNG.uniform(0,math.pi)))
noise=RNG.random((S,S))
alpha=np.clip(alpha*(0.65+0.35*noise),0,0.78)
rgba=np.zeros((S,S,4),dtype=np.uint8); rgba[:,:,:3]=np.array([28,30,29],dtype=np.uint8); rgba[:,:,3]=(alpha*255).astype(np.uint8)
Image.fromarray(rgba,'RGBA').filter(ImageFilter.GaussianBlur(1.2)).save(TEX_OUT/'oil_decal_v15.png', optimize=True)

# Blood / infected splatter
img=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(img)
for _ in range(40):
    cx=int(RNG.integers(70,442)); cy=int(RNG.integers(70,442)); r=int(RNG.integers(4,30));
    col=(91+int(RNG.integers(-12,15)),25,30,int(RNG.integers(70,190)))
    d.ellipse((cx-r,cy-r,cx+r,cy+r), fill=col)
for _ in range(7):
    x0=int(RNG.integers(80,430)); y0=int(RNG.integers(80,430)); x1=x0+int(RNG.integers(-80,80)); y1=y0+int(RNG.integers(-120,120));
    d.line((x0,y0,x1,y1), fill=(85,22,26,int(RNG.integers(70,140))), width=int(RNG.integers(3,10)))
img.filter(ImageFilter.GaussianBlur(0.7)).save(TEX_OUT/'blood_decal_v15.png', optimize=True)

# Long rubber skid marks
img=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(img)
for offset in (-42,42):
    pts=[]
    for yy in range(-50,S+50,8):
        xx=S//2+offset+int(10*math.sin(yy*0.025))+int(RNG.normal(0,2))
        pts.append((xx,yy))
    d.line(pts, fill=(15,17,18,120), width=17)
    d.line([(x+3,y) for x,y in pts], fill=(45,46,45,50), width=4)
img=img.filter(ImageFilter.GaussianBlur(1.0)); img.save(TEX_OUT/'skid_decal_v15.png', optimize=True)

# Scorch ring for wreck sites
alpha=np.zeros((S,S),float)
y,x=np.mgrid[0:S,0:S]
r=np.sqrt((x-S/2)**2+(y-S/2)**2)
alpha=np.clip(1.0-(r/245),0,1)**1.8
alpha*=0.55+0.35*RNG.random((S,S))
rgba=np.zeros((S,S,4),dtype=np.uint8); rgba[:,:,:3]=[24,19,18]; rgba[:,:,3]=(alpha*155).astype(np.uint8)
Image.fromarray(rgba,'RGBA').filter(ImageFilter.GaussianBlur(2.0)).save(TEX_OUT/'scorch_decal_v15.png', optimize=True)

print('generated DEADLANE v1.5 graphics assets')
