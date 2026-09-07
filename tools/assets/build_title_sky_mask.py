"""Build a vector skyline mask for the current cloudless Title artwork.

Never rewrites the background or cloud PNG. The first painted edge below the
smooth sky defines each column's skyline. Inspect when changing the background.
Requires Pillow and NumPy, like build_title_cloud_strips.py.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
rgb = np.asarray(Image.open(ROOT / "assets/ui/title/QD-13-BG.png").convert("RGB"), dtype=float) / 255.0
height, width = rgb.shape[:2]
edge = np.max(np.abs(np.diff(rgb, axis=0)), axis=2) > 0.015
edge[:int(height * 0.29)] = False
boundary = np.where(edge.any(axis=0), np.argmax(edge, axis=0), height)
# Reject isolated inpainting edges in the cloudless source; they are not terrain.
padded = np.pad(boundary, (15, 15), mode="edge")
boundary = np.median(np.stack([padded[i:i + width] for i in range(31)]), axis=0).astype(int)
# A small conservative envelope prevents foliage leaking through.
padded = np.pad(boundary, (3, 3), mode="edge")
boundary = np.minimum.reduce([padded[i:i + width] for i in range(7)])
points = " ".join(f"{x},{max(0, int(y) - 1)}" for x, y in enumerate(boundary))
svg = (
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">\n'
    f'  <rect width="{width}" height="{height}" fill="black"/>\n'
    f'  <polygon points="0,0 {points} {width},{int(boundary[-1])} {width},0" fill="white"/>\n'
    '</svg>\n'
)
destination = ROOT / "assets/ui/title/clouds/sky_mask.svg"
destination.write_text(svg, encoding="utf-8")
print(destination)
