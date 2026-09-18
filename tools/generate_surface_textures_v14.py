#!/usr/bin/env python3
"""Generate original v1.4 PBR-ish tiled textures for DEADLANE."""
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'textures'
OUT.mkdir(parents=True, exist_ok=True)
SIZE=512
rng=np.random.default_rng(140913)

def norm_map(height, strength=2.5):
    h=height.astype(np.float32)/255.0
    gy,gx=np.gradient(h)
    nx=-gx*strength; ny=-gy*strength; nz=np.ones_like(h)
    n=np.sqrt(nx*nx+ny*ny+nz*nz)
    rgb=np.stack([(nx/n*0.5+0.5)*255,(ny/n*0.5+0.5)*255,(nz/n*0.5+0.5)*255],axis=-1)
    return np.clip(rgb,0,255).astype(np.uint8)

def save_set(name, base, rough_base, pattern='noise'):
    y,x=np.mgrid[0:SIZE,0:SIZE]
    noise=rng.normal(0,1,(SIZE,SIZE))
    coarse=np.array(Image.fromarray(np.uint8(np.clip((noise-noise.min())/(noise.max()-noise.min())*255,0,255))).filter(ImageFilter.GaussianBlur(4)),dtype=float)/255.0
    fine=(noise-noise.min())/(noise.max()-noise.min())
    h=0.45*coarse+0.55*fine
    if pattern=='brick':
        h=np.zeros((SIZE,SIZE),float)+0.55
        bh,bw=54,104
        for row in range(0,SIZE,bh):
            off=(row//bh%2)*(bw//2)
            for col in range(-bw,SIZE+bw,bw):
                x0=col+off; y0=row
                x1=x0+bw-5; y1=min(SIZE,y0+bh-5)
                h[max(0,y0):max(0,y1),max(0,x0):max(0,x1)] = 0.65 + rng.random()*0.12
        h += rng.normal(0,0.03,h.shape)
    elif pattern=='canvas':
        h=0.5+0.12*np.sin(x*0.34)+0.12*np.sin(y*0.31)+rng.normal(0,0.04,(SIZE,SIZE))
    elif pattern=='sandbag':
        h=0.50+0.09*np.sin(x*0.20)+0.09*np.sin(y*0.23)+0.05*np.sin((x+y)*0.08)+rng.normal(0,0.035,(SIZE,SIZE))
    elif pattern=='glass':
        h=0.48+0.035*np.sin(x*0.035)+0.025*np.sin(y*0.041)+rng.normal(0,0.015,(SIZE,SIZE))
    elif pattern=='plastic':
        h=0.52+0.045*np.sin(x*0.07)+rng.normal(0,0.025,(SIZE,SIZE))
    h=np.clip(h,0,1)
    # albedo shifts with height and grime
    base=np.array(base,float)
    shade=(h-0.5)*0.22 + (coarse-0.5)*0.13
    rgb=np.clip(base[None,None,:]*(1+shade[...,None]),0,255)
    # dark grime flecks
    specks=rng.random((SIZE,SIZE))<0.008
    rgb[specks]*=0.42
    Image.fromarray(rgb.astype(np.uint8),'RGB').save(OUT/f'{name}_albedo.png',optimize=True)
    Image.fromarray(norm_map(np.uint8(h*255),3.0),'RGB').save(OUT/f'{name}_normal.png',optimize=True)
    rough=np.clip((rough_base + (0.5-h)*0.20 + rng.normal(0,0.035,h.shape))*255,0,255).astype(np.uint8)
    Image.fromarray(rough,'L').save(OUT/f'{name}_roughness.png',optimize=True)

save_set('brick',[103,84,76],0.88,'brick')
save_set('olive_canvas',[77,85,60],0.92,'canvas')
save_set('sandbag',[132,119,88],0.97,'sandbag')
save_set('dirty_glass',[66,82,88],0.34,'glass')
save_set('hazard_plastic',[188,123,42],0.63,'plastic')
save_set('rubber',[30,32,34],0.91,'noise')
print('generated v1.4 texture sets')
