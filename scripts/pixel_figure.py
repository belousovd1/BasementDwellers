"""Shared drawing code for the boss sprites drawn in code (rafi_sprite.py and
alex_sprite.py): shapes, the outlining pass, detail helpers and PNG output.

A figure is a list of parts drawn back to front. Each part is
(name, fill, shape): the fill is WHITE, BLACK or DITHER (a black and white
checker), and the shape is a function telling whether a canvas point is inside
the part. Once every part is drawn, each one gets a white outline where it
meets empty canvas, and a line in the other colour where it lies over a part of
the same colour, unless the two are listed together in `same` as one piece.
Detail pixels go on top of that."""
import math
import os
import struct
import zlib

W, H = 96, 128
WHITE, BLACK, DITHER = 'W', 'B', 'D'


def polygon(points):
    def inside(x, y):
        hit = False
        n = len(points)
        for i in range(n):
            (x0, y0), (x1, y1) = points[i], points[(i + 1) % n]
            if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
                hit = not hit
        return hit
    return inside


def limb(joints, radii):
    """A chain of segments through joints, tapering between the given radii."""
    def inside(x, y):
        for i in range(len(joints) - 1):
            (ax, ay), (bx, by) = joints[i], joints[i + 1]
            dx, dy = bx - ax, by - ay
            t = max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy)))
            r = radii[i] + (radii[i + 1] - radii[i]) * t
            if math.hypot(x - (ax + t * dx), y - (ay + t * dy)) <= r:
                return True
        return False
    return inside


def ellipse(cx, cy, rx, ry):
    return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1


def moved(points, by):
    """Points shifted by the offset [param by], e.g. from a head's own grid."""
    return [(x + by[0], y + by[1]) for x, y in points]


class Figure:
    def __init__(self, parts, same=()):
        order = {name: i for i, (name, _, _) in enumerate(parts)}
        self.part_at = [[None] * W for _ in range(H)]
        color = [[None] * W for _ in range(H)]
        for name, fill, shape in parts:
            for y in range(H):
                for x in range(W):
                    if shape(x + 0.5, y + 0.5):
                        self.part_at[y][x] = name
                        if fill == DITHER:
                            color[y][x] = BLACK if (x + y) % 2 else WHITE
                        else:
                            color[y][x] = fill
        self.out = [row[:] for row in color]
        for y in range(H):
            for x in range(W):
                name = self.part_at[y][x]
                if name is None:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    other = self.part_at[ny][nx] if 0 <= nx < W and 0 <= ny < H else None
                    if other is None:
                        self.out[y][x] = WHITE
                    elif other != name and order[other] < order[name] and color[ny][nx] == color[y][x] \
                            and not any(name in group and other in group for group in same):
                        self.out[y][x] = BLACK if color[y][x] == WHITE else WHITE

    def set(self, x, y, c):
        """Recolours a pixel of the figure; empty canvas stays empty."""
        if 0 <= x < W and 0 <= y < H and self.out[y][x] is not None:
            self.out[y][x] = c

    def pixels(self, points, c, at=(0, 0)):
        for x, y in points:
            self.set(at[0] + x, at[1] + y, c)

    def curve(self, start, control, end, c, within, at=(0, 0)):
        """A curve through three points, drawn only over the part [param within]."""
        for i in range(41):
            t = i / 40
            x = (1 - t) ** 2 * start[0] + 2 * (1 - t) * t * control[0] + t ** 2 * end[0]
            y = (1 - t) ** 2 * start[1] + 2 * (1 - t) * t * control[1] + t ** 2 * end[1]
            px, py = at[0] + int(round(x)), at[1] + int(round(y))
            if 0 <= px < W and 0 <= py < H and self.part_at[py][px] == within:
                self.set(px, py, c)

    def ring(self, cx, cy, rx, ry, c, at=(0, 0)):
        """An ellipse outline one pixel thick."""
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                d = ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2
                if 0.62 <= d <= 1.08:
                    self.set(at[0] + x, at[1] + y, c)

    def row(self, y, x0, x1, c, over):
        """Recolours row [param y] from x0 to x1, where it is currently [param over]."""
        for x in range(x0, x1):
            if self.out[y][x] == over:
                self.set(x, y, c)

    def save(self, path, preview_path):
        """Writes the figure, and a preview five times the size on a dark grey."""
        rgba = bytearray(W * H * 4)
        for y in range(H):
            for x in range(W):
                c = self.out[y][x]
                if c is not None:
                    rgba[(y * W + x) * 4:(y * W + x) * 4 + 4] = \
                        b'\xff\xff\xff\xff' if c == WHITE else b'\x00\x00\x00\xff'
        os.makedirs(os.path.dirname(path), exist_ok=True)
        _write_png(path, W, H, bytes(rgba))
        scale = 5
        prev = bytearray()
        for y in range(H):
            line = bytearray()
            for x in range(W):
                px = rgba[(y * W + x) * 4:(y * W + x) * 4 + 4]
                line += (bytes(px) if px[3] else b'\x30\x30\x40\xff') * scale
            prev += bytes(line) * scale
        _write_png(preview_path, W * scale, H * scale, bytes(prev))
        ys = [y for y in range(H) if any(self.out[y][x] for x in range(W))]
        xs = [x for x in range(W) if any(self.out[y][x] for y in range(H))]
        print(f'Wrote {path}: the figure spans x {xs[0]}-{xs[-1]}, y {ys[0]}-{ys[-1]}')


def _write_png(path, w, h, rgba):
    raw = b''.join(b'\x00' + rgba[y * w * 4:(y + 1) * w * 4] for y in range(h))

    def chunk(t, data):
        c = t + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                           + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))
