"""Rectify the individually traced cloud ribbons into parallel texture strips.
Run with the supplied QD-13-BG (5).png as the first argument.
The traces use a 1760 x 1408 reference canvas; no generated cloud painting is used.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter
from collections import deque

# Centerlines and local half widths: near and far ends are rescaled independently.
TRACES = [
 [(190,550,55),(260,690,95),(355,840,70),(465,960,40),(568,1050,15)],
 [(520,95,42),(556,200,80),(598,298,50)],
 [(475,360,38),(560,485,90),(675,635,110),(731,780,68),(785,930,28),(824,1010,12)],
 [(1233,162,20),(1244,253,33),(1203,363,35),(1120,503,36),(1062,649,44),(975,814,37),(910,976,27),(889,1110,10)],
 [(1610,148,20),(1542,240,40),(1464,350,45),(1360,474,62),(1322,641,68),(1250,825,62),(1129,1010,43),(1007,1195,12)],
 [(1667,678,18),(1590,727,38),(1510,803,35),(1430,881,12)],
 [(604,1140,18),(672,1200,25),(759,1250,20),(840,1280,8)],
]
size = (384, 1536)
source = Image.open(sys.argv[1]).convert('RGBA')
out = Path(__file__).resolve().parents[2] / 'assets/ui/title/clouds'
out.mkdir(parents=True, exist_ok=True)
atlas = Image.new('RGBA', (size[0]*len(TRACES),size[1]))
for index, trace in enumerate(TRACES):
 p=np.array(trace,dtype=float)
 seg=np.linalg.norm(np.diff(p[:,:2],axis=0),axis=1)
 arc=np.r_[0,np.cumsum(seg)]
 # Affine strip extraction preserves the painting's local brushwork. Only
 # transverse size is compensated; never nonlinearly stretch its length.
 t=np.linspace(0,1,size[1])
 direction=p[-1,:2]-p[0,:2]
 length=np.linalg.norm(direction)
 tangent=direction/length
 normal=np.array([tangent[1],-tangent[0]])
 centers=p[0,:2]+t[:,None]*direction
 # Cover all traced bends without cutting through the cloud itself.
 offsets=(p[:,:2]-p[0,:2])@normal
 half_width=max(np.max(np.abs(offsets)+p[:,2]),30)*1.35
 lateral=np.linspace(-1,1,size[0])[None,:]
 width=half_width*(1.0-.18*t)
 sx=centers[:,0,None]+normal[0]*width[:,None]*lateral
 sy=centers[:,1,None]+normal[1]*width[:,None]*lateral
 # Pillow MESH isn't needed: bilinear remapping retains original painted RGB.
 a=np.asarray(source).astype(float)/255
 x=np.clip(sx/1760*(source.width-1),0,source.width-2);y=np.clip(sy/1408*(source.height-1),0,source.height-2)
 ix=x.astype(int);iy=y.astype(int);fx=(x-ix)[...,None];fy=(y-iy)[...,None]
 c=(a[iy,ix]*(1-fx)+a[iy,ix+1]*fx)*(1-fy)+(a[iy+1,ix]*(1-fx)+a[iy+1,ix+1]*fx)*fy
 k=np.clip((np.minimum(c[:,:,0],c[:,:,1])/np.maximum(c[:,:,2],.001)-.58)/.25,0,1); k=k*k*(3-2*k)
 edge=np.clip((1.25-np.abs(lateral))/.15,0,1)
 ends=np.minimum(np.clip(t/.10,0,1),np.clip((1-t)/.10,0,1))[:,None]
 c[:,:,3]*=k*edge*ends
 img=Image.fromarray(np.uint8(np.clip(c,0,1)*255),'RGBA')
 # Keep the actual cloud body, not disconnected scraps from neighboring cuts.
 small=np.asarray(img.getchannel('A').resize((96,384)))>48
 visited=np.zeros_like(small,dtype=bool); biggest=[]
 for yy,xx in zip(*np.where(small)):
  if visited[yy,xx]: continue
  queue=deque([(yy,xx)]);visited[yy,xx]=True;component=[]
  while queue:
   y0,x0=queue.popleft();component.append((y0,x0))
   for y1,x1 in ((y0-1,x0),(y0+1,x0),(y0,x0-1),(y0,x0+1)):
    if 0<=y1<384 and 0<=x1<96 and small[y1,x1] and not visited[y1,x1]:
     visited[y1,x1]=True;queue.append((y1,x1))
  if len(component)>len(biggest):biggest=component
 mask=np.zeros((384,96),dtype=np.uint8)
 for yy,xx in biggest:mask[yy,xx]=255
 support=Image.fromarray(mask).filter(ImageFilter.MaxFilter(9)).resize(size,Image.Resampling.BILINEAR)
 alpha=np.asarray(img.getchannel('A')).astype(float)*np.asarray(support)/255
 img.putalpha(Image.fromarray(alpha.astype('uint8')))
 img.save(out/f'cloud_strip_{index+1:02}.png');atlas.paste(img,(index*size[0],0))
atlas.save(out/'title_cloud_strips.png')
preview=atlas.copy();preview.thumbnail((1075,615));preview.save('/tmp/cloud-strip-preview.png')
