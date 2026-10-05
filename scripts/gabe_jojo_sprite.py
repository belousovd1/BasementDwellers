"""Draws Assets/Sprites/Gabe/gabe.png: Gabe standing in a JoJo pose, his head
taken from the Gabe layer of gabe.ase and put on a body drawn here.

The body is built from simple shapes (polygons and tapered limbs), drawn back
to front, then outlined in the same style as Mike: white lines on black, with
white skin and trousers. Rerun it after changing the head or the pose:

    python scripts/gabe_jojo_sprite.py

It also writes gabe_head.png, the head on its own for the dialogue portrait,
and gabe_preview.png, five times the size, next to this script."""
import math
import os
import struct
import zlib

W, H = 96, 128
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASE = os.path.join(ROOT, 'Assets', 'Sprites', 'Gabe', 'gabe.ase')
OUT = os.path.join(ROOT, 'Assets', 'Sprites', 'Gabe', 'gabe.png')
HEAD_OUT = os.path.join(ROOT, 'Assets', 'Sprites', 'Gabe', 'gabe_head.png')
PREVIEW = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gabe_preview.png')
WHITE, BLACK = 'W', 'B'

# Where Gabe's 30x32 head cel goes on the canvas.
HEAD_AT = (38, 3)


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


# Back to front. Each part: name, fill, shape. A JoJo pose: weight on one
# straight leg, the other knee swung across, hips cocked one way and shoulders
# tilted the other, one arm flung up with the hand splayed and the other thrust
# out pointing down at whoever he's fighting.
PARTS = [
    # Weight-bearing leg on the right, nearly straight.
    ('back_leg', WHITE, limb([(64, 72), (69, 95), (68, 115)], [6.5, 5.0, 3.8])),
    ('back_shoe', BLACK, polygon([(63, 113), (71, 113), (79, 117), (79, 121), (62, 121)])),
    # Bent leg, knee swung in across the other one, foot out on tiptoe.
    ('front_leg', WHITE, limb([(51, 72), (61, 93), (49, 112)], [6.5, 5.0, 3.8])),
    ('front_shoe', BLACK, polygon([(45, 109), (53, 110), (52, 117), (42, 120), (40, 117)])),
    # Broad, tilted shoulders down to a pinched waist, hips pushed right.
    ('torso', BLACK, polygon([(32, 36), (44, 31), (63, 32), (75, 39), (73, 48), (66, 56), (63, 62),
                              (68, 67), (46, 68), (47, 57), (39, 47)])),
    ('hips', WHITE, polygon([(46, 66), (68, 65), (71, 75), (47, 76)])),
    # Raised arm: upper arm up and out with the bicep bulging under it, elbow
    # high, forearm angled back in towards his head.
    ('raised_arm_upper', WHITE, limb([(36, 37), (21, 25)], [6.0, 4.6])),
    ('raised_bicep', WHITE, ellipse(26.5, 32.5, 6.0, 4.6)),
    ('raised_arm_lower', WHITE, limb([(21, 25), (28, 17)], [4.8, 2.8])),
    ('raised_sleeve', BLACK, limb([(40, 38), (36.5, 36)], [6.0, 5.6])),
    # Pointing arm: out and down, forearm tapering to the wrist, then a fist
    # with the thumb on top and the index finger aimed down at the player.
    ('point_arm_upper', WHITE, limb([(73, 43), (83, 50)], [6.0, 4.8])),
    ('point_arm_lower', WHITE, limb([(83, 50), (87, 56)], [4.8, 3.0])),
    ('point_fist', WHITE, ellipse(88, 59, 3.8, 3.4)),
    ('point_thumb', WHITE, limb([(87, 56), (91.5, 57.5)], [1.4, 1.1])),
    ('point_finger', WHITE, limb([(89.5, 60.5), (94.5, 66)], [1.4, 1.1])),
    ('point_sleeve', BLACK, limb([(70, 40), (73, 42)], [6.0, 5.6])),
    ('head', None, None),
    # The raised hand clawed beside his face, fingers splayed.
    ('raised_palm', WHITE, ellipse(30, 14, 3.5, 3.3)),
    ('raised_thumb', WHITE, limb([(28, 11), (27.5, 7), (29.5, 4)], [1.4, 1.2, 1.0])),
    ('raised_index', WHITE, limb([(32, 11), (34.5, 6.5), (37, 5)], [1.3, 1.2, 1.0])),
    ('raised_middle', WHITE, limb([(33, 13), (36.5, 10.5), (38.5, 11.5)], [1.3, 1.2, 1.0])),
    ('raised_ring', WHITE, limb([(33, 15), (36.5, 15.5), (38, 17.5)], [1.3, 1.2, 1.0])),
    ('raised_pinky', WHITE, limb([(32, 17), (34.5, 20), (35.5, 22.5)], [1.3, 1.1, 0.9])),
]
ORDER = {name: i for i, (name, _, _) in enumerate(PARTS)}
# Parts outlined in black where they meet the rest of the same limb, so the
# muscles and hands show inside the white of the arm.
CONTOURED = {'raised_bicep', 'raised_arm_lower', 'raised_palm', 'point_arm_lower', 'point_fist'}


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
                elif name in CONTOURED and other != name and _same_cloth(name, other):
                    out[y][x] = BLACK
    _details(out, part_at)
    return out, part_at


def _same_cloth(a, b):
    """Parts that are one piece of clothing or body, so no line between them."""
    groups = [{'torso', 'raised_sleeve', 'point_sleeve'}, {'hips', 'back_leg'}, {'hips', 'front_leg'},
              {'raised_arm_upper', 'raised_bicep', 'raised_arm_lower', 'raised_palm', 'raised_pinky',
               'raised_ring', 'raised_middle', 'raised_index', 'raised_thumb'},
              {'point_arm_upper', 'point_arm_lower', 'point_fist', 'point_thumb', 'point_finger'}]
    return any(a in g and b in g for g in groups)


def _set(out, x, y, c):
    if 0 <= x < W and 0 <= y < H and out[y][x] is not None:
        out[y][x] = c


def _details(out, part_at):
    # Pecs: a line down the middle of the chest and one under each side.
    for y in range(37, 46):
        _set(out, 55, y, WHITE)
    for x, y in [(45, 44), (46, 45), (47, 46), (48, 46), (49, 46), (50, 46), (51, 46), (52, 46), (53, 45), (54, 45),
                 (56, 45), (57, 45), (58, 46), (59, 46), (60, 46), (61, 46), (62, 46), (63, 46), (64, 45), (65, 44)]:
        _set(out, x, y, WHITE)
    # Abs.
    for y in (51, 56, 61):
        for x in list(range(51, 54)) + list(range(57, 60)):
            _set(out, x, y, WHITE)
    for y in range(49, 64):
        _set(out, 55, y, WHITE)
    # The Apple logo, small, on the left pec.
    logo = [
        '..#.',
        '.##.',
        '####',
        '###.',
        '.##.',
    ]
    for yy, row in enumerate(logo):
        for xx, ch in enumerate(row):
            if ch == '#':
                _set(out, 47 + xx, 37 + yy, WHITE)
    # The curled fingers on the pointing fist.
    for x, y in [(86, 60), (87, 61)]:
        _set(out, x, y, BLACK)
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
    for x in range(40, 80):
        if part_at[120][x] == 'back_shoe':
            _set(out, x, 120, WHITE)


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
    # The head alone, without the raised hand in front of it.
    hw, hh, head = read_head()
    pixels = []
    for i in range(0, hw * hh * 4, 4):
        if not head[i + 3]:
            pixels.append(b'\x00\x00\x00\x00')
        else:
            pixels.append(b'\xff\xff\xff\xff' if head[i] > 128 else b'\x00\x00\x00\xff')
    write_png(HEAD_OUT, hw, hh, b''.join(pixels))
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
