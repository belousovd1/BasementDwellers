"""Draws Assets/Sprites/Alex/alex.png: Alex standing with his electric guitar,
in the same style as the other bosses: white lines on black, white skin.

Built like rafi_sprite.py, from shapes and detail pixels; see pixel_figure.py.
He faces front: a baseball cap, big round glasses, stubble and a grin, a black
hoodie, shorts and trainers, with a white guitar slung across him, strumming
with his right hand and fretting with his left.

    python scripts/alex_sprite.py

It also writes alex_preview.png, five times the size, next to this script."""
import os

from pixel_figure import BLACK, WHITE, Figure, ellipse, limb, moved, polygon

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Assets', 'Sprites', 'Alex', 'alex.png')
PREVIEW = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'alex_preview.png')

# Where the head's own 34x40 grid sits on the canvas.
HEAD = (33, 0)


def head(points):
    return moved(points, HEAD)


def union(*shapes):
    return lambda x, y: any(shape(x, y) for shape in shapes)


# Back to front. Each part: name, fill, shape.
PARTS = [
    # Shorts, bare calves and trainers, standing a little apart.
    ('left_calf', WHITE, limb([(41, 89), (39, 111)], [4.2, 3.4])),
    ('right_calf', WHITE, limb([(60, 89), (62, 111)], [4.2, 3.4])),
    ('left_shoe', BLACK, polygon([(34, 110), (43, 110), (44, 120), (30, 120), (30, 117)])),
    ('right_shoe', BLACK, polygon([(57, 110), (66, 110), (70, 117), (70, 120), (56, 120)])),
    ('left_short', BLACK, limb([(43, 78), (41, 89)], [7.0, 6.2])),
    ('right_short', BLACK, limb([(57, 78), (60, 89)], [7.0, 6.2])),
    ('hips', BLACK, polygon([(36, 74), (64, 74), (66, 84), (34, 84)])),
    ('neck', WHITE, polygon(head([(12, 28), (22, 28), (23, 39), (11, 39)]))),
    # The hoodie, with the hood bunched round his neck.
    ('torso', BLACK, polygon([(37, 40), (45, 37), (55, 37), (63, 40), (67, 46), (66, 60), (65, 76),
                              (35, 76), (34, 60), (33, 46)])),
    ('hood', BLACK, ellipse(HEAD[0] + 17, HEAD[1] + 38.5, 10.5, 3.6)),
    # The fretting arm's upper arm hangs behind the guitar.
    ('fret_upper_arm', BLACK, limb([(64, 44), (72, 59)], [4.6, 4.0])),
    # The strap over his shoulder, then the guitar: body low on the left, the
    # neck rising across him to the headstock on the right.
    ('strap', WHITE, limb([(62, 39), (46, 64)], [1.1, 1.1])),
    ('guitar_body', WHITE, union(ellipse(40, 76, 9.5, 7.0), ellipse(47, 69, 7.0, 6.0))),
    ('guitar_neck', WHITE, limb([(50, 67), (77, 46)], [2.0, 1.7])),
    ('headstock', WHITE, polygon([(75, 46), (78, 41), (83, 39), (84, 42), (80, 47)])),
    # Strumming arm, down by the body; fretting hand round the neck.
    ('strum_arm', BLACK, limb([(36, 44), (31, 62), (39, 71)], [4.6, 4.0, 3.6])),
    ('strum_hand', WHITE, ellipse(41.5, 71.5, 3.1, 2.8)),
    ('fret_forearm', BLACK, limb([(72, 59), (70, 51)], [4.0, 3.5])),
    ('fret_hand', WHITE, ellipse(69.5, 50.0, 2.9, 3.1)),
    # The head: ears behind the face, stubble on the jaw, then the cap.
    ('left_ear', WHITE, ellipse(HEAD[0] + 6.5, HEAD[1] + 20.5, 2.3, 3.6)),
    ('right_ear', WHITE, ellipse(HEAD[0] + 27.5, HEAD[1] + 20.5, 2.3, 3.6)),
    ('face', WHITE, polygon(head([(8, 12), (26, 12), (27, 18), (26, 25), (23, 30), (19, 33), (15, 33),
                                  (11, 30), (8, 25), (7, 18)]))),
    ('sideburns', BLACK, union(polygon(head([(8, 12), (9, 12), (9, 17), (8, 17)])),
                               polygon(head([(25, 12), (26, 12), (26, 17), (25, 17)])))),
    ('crown', BLACK, polygon(head([(5, 12), (5, 8), (8, 4), (13, 1), (21, 1), (26, 4), (29, 8), (29, 12)]))),
    # The cap's bill, facing forward and curving down over his forehead.
    ('brim', BLACK, polygon(head([(4, 10), (30, 10), (30, 13), (26, 15), (17, 16), (8, 15), (4, 13)]))),
]
# Parts that are one piece, so no line is drawn where they meet.
SAME = [{'hips', 'left_short'}, {'hips', 'right_short'}, {'left_short', 'right_short'},
        {'face', 'neck'}, {'face', 'sideburns'}, {'torso', 'fret_upper_arm'},
        {'fret_upper_arm', 'fret_forearm'}, {'guitar_body', 'guitar_neck'}, {'guitar_neck', 'headstock'}]


def details(figure):
    # Cap: the button on top, panel seams and a little logo on the front.
    figure.pixels([(17, 1)], WHITE, HEAD)
    figure.curve((17, 2), (12, 4), (10, 9), WHITE, 'crown', HEAD)
    figure.curve((17, 2), (22, 4), (24, 9), WHITE, 'crown', HEAD)
    figure.pixels([(16, 6), (17, 5), (18, 6), (17, 7)], WHITE, HEAD)
    # Big round glasses, with their arms back to the ears.
    figure.ring(12.3, 19.2, 3.9, 3.8, BLACK, HEAD)
    figure.ring(21.7, 19.2, 3.9, 3.8, BLACK, HEAD)
    figure.pixels([(16, 18), (17, 18), (8, 18), (26, 18)], BLACK, HEAD)
    # Eyes.
    figure.pixels([(12, 19), (13, 19), (12, 20), (13, 20), (21, 19), (22, 19), (21, 20), (22, 20)], BLACK, HEAD)
    # Nose.
    figure.pixels([(17, 21), (17, 22), (16, 23), (18, 23)], BLACK, HEAD)
    # A wide grin with teeth, under a light moustache, and stubble on the jaw.
    figure.pixels([(13, 26), (14, 26), (15, 26), (16, 26), (17, 26), (18, 26), (19, 26), (20, 26), (21, 26),
                   (14, 27), (20, 27), (15, 28), (16, 28), (17, 28), (18, 28), (19, 28)], BLACK, HEAD)
    figure.pixels([(15, 27), (16, 27), (17, 27), (18, 27), (19, 27)], WHITE, HEAD)
    figure.pixels([(14, 24), (15, 25), (17, 24), (19, 25), (20, 24)], BLACK, HEAD)
    figure.pixels([(9, 25), (10, 27), (12, 29), (14, 31), (17, 31), (20, 31), (22, 29), (24, 27), (25, 25),
                   (16, 30), (18, 30), (11, 28), (23, 28)], BLACK, HEAD)
    # Insides of the ears.
    figure.pixels([(6, 20), (6, 21), (28, 20), (28, 21)], BLACK, HEAD)
    # Hoodie drawstrings.
    figure.pixels([(46, 41), (46, 42), (45, 43), (45, 44), (54, 41), (54, 42), (55, 43), (55, 44)], WHITE)
    # The guitar: two pickups, the bridge, knobs, strings up the neck, frets and
    # tuning pegs.
    figure.pixels([(43, 70), (44, 70), (45, 69), (40, 73), (41, 73), (42, 72)], BLACK)
    figure.pixels([(37, 76), (38, 76), (39, 75), (36, 79), (40, 80)], BLACK)
    for i in range(2, 26, 3):
        figure.set(50 + i, round(67 - i * 21 / 27), BLACK)
    figure.pixels([(80, 41), (82, 40), (79, 44)], BLACK)
    # Kangaroo pocket on the hoodie, and the hem.
    figure.row(75, 50, 65, WHITE, over=BLACK)
    # Hems of the shorts, knees, and soles of the trainers.
    figure.row(90, 34, 47, WHITE, over=BLACK)
    figure.row(90, 54, 67, WHITE, over=BLACK)
    figure.pixels([(36, 113), (38, 114), (40, 113), (59, 113), (61, 114), (63, 113)], WHITE)
    figure.row(119, 30, 71, WHITE, over=BLACK)


if __name__ == '__main__':
    alex = Figure(PARTS, SAME)
    details(alex)
    alex.save(OUT, PREVIEW)
