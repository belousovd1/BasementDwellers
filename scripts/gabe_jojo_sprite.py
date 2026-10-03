"""Draws Assets/Sprites/Gabe/gabe.png: Gabe standing in a JoJo pose, his head
taken from the Gabe layer of gabe.ase and put on a body drawn here.

The body is built from simple shapes (polygons and tapered limbs), drawn back
to front, then outlined in the same style as Mike: white lines on black, with
white skin and trousers. Rerun it after changing the head or the pose:

    python scripts/gabe_jojo_sprite.py

It also writes gabe_preview.png, five times the size, next to this script."""
import math
import os
import struct
import zlib

W, H = 96, 128
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASE = os.path.join(ROOT, 'Assets', 'Sprites', 'Gabe', 'gabe.ase')
OUT = os.path.join(ROOT, 'Assets', 'Sprites', 'Gabe', 'gabe.png')
PREVIEW = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gabe_preview.png')
WHITE, BLACK = 'W', 'B'

# Where Gabe's 30x32 head cel goes on the canvas.
HEAD_AT = (38, 3)

# The raised hand: palm beside the face, index and middle fingers held up in a
# V across the temple. Top-left pixel goes at HAND_AT.
HAND = [
    '........##..##',
    '.......##..##.',
    '......##..##..',
    '.....##..##...',
    '....######....',
    '...#######....',
    '..########....',
    '..#######.....',
    '...######.....',
    '....####......',
    '....###.......',
]
HAND_AT = (31, 7)


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


def bitmap(rows, at):
    cells = {(at[0] + x, at[1] + y) for y, row in enumerate(rows) for x, ch in enumerate(row) if ch == '#'}
    return lambda x, y: (int(x), int(y)) in cells


def ellipse(cx, cy, rx, ry):
    return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1


# Back to front. Each part: name, fill, shape.
PARTS = [
    # Weight-bearing leg on the right, nearly straight.
    ('back_leg', WHITE, limb([(64, 72), (69, 95), (68, 115)], [5.5, 4.2, 3.4])),
    ('back_shoe', BLACK, polygon([(63, 113), (71, 113), (78, 117), (78, 121), (62, 121)])),
    # Bent leg, knee swung in across the other one, foot out on tiptoe.
    ('front_leg', WHITE, limb([(51, 72), (61, 93), (49, 112)], [5.5, 4.3, 3.4])),
    ('front_shoe', BLACK, polygon([(45, 109), (53, 110), (52, 117), (42, 120), (40, 117)])),
    # Arm on the hip, elbow out; the upper arm is behind the body.
    ('hip_arm_upper', WHITE, limb([(66, 40), (80, 52)], [4.2, 3.6])),
    ('hip_sleeve', BLACK, limb([(66, 39), (73, 45)], [5.0, 4.6])),
    # Torso, leaning left at the shoulders, waist pinched, hips pushed right.
    ('torso', BLACK, polygon([(43, 35), (53, 32), (66, 35), (70, 41), (66, 51), (63, 58), (68, 67),
                              (46, 68), (46, 56), (41, 44)])),
    ('hips', WHITE, polygon([(46, 66), (68, 65), (71, 75), (47, 76)])),
    ('hip_arm_lower', WHITE, limb([(80, 52), (70, 63)], [3.6, 3.0])),
    ('hip_hand', WHITE, ellipse(68.5, 64.5, 3.5, 3.2)),
    # Raised arm: elbow high out to the side, forearm up to the face.
    ('raised_arm_upper', WHITE, limb([(43, 39), (25, 26)], [4.2, 3.6])),
    ('raised_sleeve', BLACK, limb([(44, 39), (36, 33)], [5.0, 4.6])),
    ('raised_arm_lower', WHITE, limb([(25, 26), (36, 17)], [3.6, 3.0])),
    ('head', None, None),
    ('raised_hand', WHITE, bitmap(HAND, HAND_AT)),
]
ORDER = {name: i for i, (name, _, _) in enumerate(PARTS)}


def read_head():
    d = open(ASE, 'rb').read()
    oldc = struct.unpack('<H', d[134:136])[0]
    newc = struct.unpack('<I', d[140:144])[0] or oldc
    p, layers = 144, []
    for _ in range(newc):
        csize, ctype = struct.unpack('<IH', d[p:p + 6])
        body = d[p + 6:p + csize]
        if ctype == 0x2004:
            n = struct.unpack('<H', body[16:18])[0]
            layers.append(body[18:18 + n].decode())
        elif ctype == 0x2005:
            li = struct.unpack('<H', body[:2])[0]
            cw, ch = struct.unpack('<HH', body[16:20])
            if layers[li] == 'Gabe':
                return cw, ch, zlib.decompress(body[20:])
        p += csize


def draw():
    part_at = [[None] * W for _ in range(H)]
    color = [[None] * W for _ in range(H)]
    hw, hh, head = read_head()
    for name, fill, shape in PARTS:
        if name == 'head':
            for yy in range(hh):
                for xx in range(hw):
                    s = (yy * hw + xx) * 4
                    if head[s + 3]:
                        x, y = HEAD_AT[0] + xx, HEAD_AT[1] + yy
                        part_at[y][x] = 'head'
                        color[y][x] = WHITE if head[s] > 128 else BLACK
            continue
        for y in range(H):
            for x in range(W):
                if shape(x + 0.5, y + 0.5):
                    part_at[y][x] = name
                    color[y][x] = fill

    # Outlines: white around the figure, and a line in the other colour where a
    # part lies over another part of the same colour.
    out = [row[:] for row in color]
    for y in range(H):
        for x in range(W):
            name = part_at[y][x]
            if name is None or name == 'head':
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                other = part_at[ny][nx] if 0 <= nx < W and 0 <= ny < H else None
                if other is None:
                    out[y][x] = WHITE
                elif other != name and other != 'head' and ORDER[other] < ORDER[name] \
                        and color[ny][nx] == color[y][x] and not _same_cloth(name, other):
                    out[y][x] = BLACK if color[y][x] == WHITE else WHITE
    _details(out, part_at)
    return out, part_at


def _same_cloth(a, b):
    """Parts that are one piece of clothing or body, so no line between them."""
    groups = [{'torso', 'hip_sleeve', 'raised_sleeve'}, {'hips', 'back_leg'}, {'hips', 'front_leg'},
              {'hip_arm_upper', 'hip_arm_lower', 'hip_hand'},
              {'raised_arm_upper', 'raised_arm_lower', 'raised_hand'}]
    return any(a in g and b in g for g in groups)


def _set(out, x, y, c):
    if 0 <= x < W and 0 <= y < H and out[y][x] is not None:
        out[y][x] = c


def _details(out, part_at):
    # The Apple logo on the chest.
    logo = [
        '...#.',
        '..#..',
        '.##.#',
        '####.',
        '###..',
        '####.',
        '.###.',
    ]
    for yy, row in enumerate(logo):
        for xx, ch in enumerate(row):
            if ch == '#':
                _set(out, 57 + xx, 42 + yy, WHITE)
    # A lanyard from the collar to a badge.
    for x, y in [(49, 35), (49, 36), (50, 37), (50, 38), (50, 39), (51, 40), (51, 41), (51, 42),
                 (51, 43), (51, 44), (51, 45)]:
        _set(out, x, y, WHITE)
    for x in range(49, 54):
        for y in range(46, 50):
            _set(out, x, y, WHITE if x in (49, 53) or y in (46, 49) else BLACK)
    # Belt line and fly on the trousers.
    for x in range(46, 70):
        if part_at[67][x] == 'hips':
            _set(out, x, 67, BLACK)
    for y in range(68, 74):
        _set(out, 59, y, BLACK)
    # Knee creases.
    for x, y in [(60, 91), (61, 92), (62, 92), (68, 94), (69, 95)]:
        _set(out, x, y, BLACK)
    # Shoe soles.
    for x in range(62, 79):
        if part_at[120][x] == 'back_shoe':
            _set(out, x, 120, WHITE)
    # Curled fingers on the raised hand.
    for x, y in [(35, 14), (36, 15), (37, 15), (35, 16)]:
        _set(out, x, y, BLACK)
    # Shirt folds at the waist.
    for x, y in [(49, 58), (50, 59), (61, 55), (60, 56)]:
        _set(out, x, y, WHITE)


def write_png(path, w, h, rgba):
    raw = b''.join(b'\x00' + rgba[y * w * 4:(y + 1) * w * 4] for y in range(h))

    def chunk(t, data):
        c = t + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                           + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def main():
    out, _ = draw()
    rgba = bytearray(W * H * 4)
    for y in range(H):
        for x in range(W):
            c = out[y][x]
            if c is not None:
                rgba[(y * W + x) * 4:(y * W + x) * 4 + 4] = b'\xff\xff\xff\xff' if c == WHITE else b'\x00\x00\x00\xff'
    write_png(OUT, W, H, bytes(rgba))
    scale = 5
    prev = bytearray()
    for y in range(H):
        row = bytearray()
        for x in range(W):
            px = rgba[(y * W + x) * 4:(y * W + x) * 4 + 4]
            row += (bytes(px) if px[3] else b'\x30\x30\x40\xff') * scale
        prev += bytes(row) * scale
    write_png(PREVIEW, W * scale, H * scale, bytes(prev))
    ys = [y for y in range(H) if any(out[y][x] for x in range(W))]
    xs = [x for x in range(W) if any(out[y][x] for y in range(H))]
    print(f'Wrote {OUT}: the figure spans x {xs[0]}-{xs[-1]}, y {ys[0]}-{ys[-1]}')


if __name__ == '__main__':
    main()
