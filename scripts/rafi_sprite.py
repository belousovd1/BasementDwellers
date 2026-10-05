"""Draws Assets/Sprites/Rafi/rafi.png: Rafi standing with his arms crossed, in
the same style as the other bosses: white lines on black, white skin.

Everything is built from simple shapes (polygons, ellipses and tapered limbs)
drawn back to front, outlined, and then finished with hand-placed detail
pixels; see pixel_figure.py. He faces left in three-quarter view: a swept-up
quiff with short faded sides, round glasses, a short boxed beard and a black
T-shirt.

    python scripts/rafi_sprite.py

It also writes rafi_preview.png, five times the size, next to this script."""
import os

from pixel_figure import BLACK, DITHER, WHITE, Figure, ellipse, limb, moved, polygon

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Assets', 'Sprites', 'Rafi', 'rafi.png')
PREVIEW = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rafi_preview.png')

# Where the head's own 34x40 grid sits on the canvas.
HEAD = (31, 1)


def head(points):
    return moved(points, HEAD)


# Back to front. Each part: name, fill, shape.
PARTS = [
    # Legs in a wide stance, in dark jeans.
    ('left_leg', BLACK, limb([(42, 80), (38, 99), (36, 114)], [6.5, 5.6, 5.0])),
    ('right_leg', BLACK, limb([(57, 80), (61, 99), (63, 114)], [6.5, 5.6, 5.0])),
    ('hips', BLACK, polygon([(35, 72), (64, 72), (66, 83), (33, 83)])),
    ('left_shoe', WHITE, polygon([(31, 112), (41, 112), (42, 121), (27, 121), (27, 118)])),
    ('right_shoe', WHITE, polygon([(58, 112), (68, 112), (72, 118), (72, 121), (57, 121)])),
    ('neck', WHITE, polygon(head([(10, 30), (26, 27), (27, 40), (10, 40)]))),
    # The T-shirt, with broad shoulders.
    ('torso', BLACK, polygon([(36, 40), (45, 38), (54, 38), (63, 40), (67, 45), (66, 58), (64, 74),
                              (35, 74), (33, 58), (32, 45)])),
    # Arms crossed: the left upper arm, then the far forearm reaching across to
    # rest its hand on that bicep, then the near forearm, whose hand tucks
    # under the right upper arm.
    ('left_arm', WHITE, limb([(35, 44), (31, 60)], [4.8, 4.2])),
    ('left_sleeve', BLACK, limb([(36, 43), (34, 50)], [6.0, 5.6])),
    ('back_forearm', WHITE, limb([(68, 61), (39, 51)], [4.0, 3.4])),
    ('back_hand', WHITE, ellipse(36.0, 50.5, 3.2, 2.9)),
    ('front_forearm', WHITE, limb([(31, 61), (62, 58)], [4.3, 3.7])),
    ('right_arm', WHITE, limb([(64, 44), (68, 61)], [4.8, 4.2])),
    ('right_sleeve', BLACK, limb([(63, 43), (65, 50)], [6.0, 5.6])),
    # The head: skull and face, an ear, the beard on the jaw, then the hair:
    # a quiff swept up at the front, short and faded above the ear.
    ('face', WHITE, polygon(head([(5, 12), (14, 10), (25, 10), (30, 14), (31, 20), (29, 27), (25, 32),
                                  (19, 35), (12, 35), (8, 33), (6, 30), (4, 28), (4, 26), (2, 24), (2, 22),
                                  (4, 19), (4, 16)]))),
    ('ear', WHITE, ellipse(HEAD[0] + 29.5, HEAD[1] + 21.5, 2.6, 4.6)),
    ('beard', BLACK, polygon(head([(29, 23), (29, 27), (25, 32), (19, 35), (12, 35), (8, 33), (6, 30), (4, 28),
                                   (4, 26), (5, 25), (9, 25), (12, 26), (14, 28), (18, 29), (22, 28), (25, 26),
                                   (27, 23)]))),
    ('fade', DITHER, polygon(head([(25, 11), (31, 10), (31, 17), (28, 17), (26, 14)]))),
    ('hair', BLACK, polygon(head([(5, 13), (3, 11), (1, 8), (1, 5), (3, 2), (5, 0), (7, 1), (9, -1),
                                  (12, 0), (14, -1), (17, 0), (20, 0), (23, 2), (26, 3), (29, 6), (31, 9),
                                  (30, 12), (26, 12), (21, 11), (15, 11), (10, 12), (7, 14)]))),
]
# Parts that are one piece, so no line is drawn where they meet.
SAME = [{'torso', 'left_sleeve', 'right_sleeve'}, {'hips', 'left_leg'}, {'hips', 'right_leg'},
        {'face', 'neck'}, {'back_forearm', 'back_hand'}, {'fade', 'hair'}]


def details(figure):
    # Strands sweeping from the back of the head up and forward into the
    # quiff, and the curl at its front.
    for strand in [((6, 12), (2, 3), (11, 1)), ((11, 11), (8, 3), (17, 1)), ((16, 11), (14, 4), (23, 3)),
                   ((21, 11), (20, 5), (28, 7)), ((25, 11), (25, 7), (29, 9))]:
        figure.curve(*strand, WHITE, 'hair', HEAD)
    figure.pixels([(3, 7), (3, 8), (4, 9)], WHITE, HEAD)
    # Eyebrows: the near one level, the far one arched, unimpressed.
    figure.pixels([(5, 15), (6, 15), (7, 14), (8, 14), (9, 14), (10, 15),
                   (14, 15), (15, 14), (16, 14), (17, 13), (18, 13), (19, 13), (20, 14), (21, 15)], BLACK, HEAD)
    # Round glasses, the near lens a little narrower, with the arm back to the ear.
    figure.ring(7.9, 19.4, 3.4, 3.4, BLACK, HEAD)
    figure.ring(18.0, 19.4, 4.0, 3.6, BLACK, HEAD)
    figure.pixels([(11, 18), (12, 18), (13, 18), (22, 18), (23, 18), (24, 18), (25, 18), (26, 18),
                   (27, 18)], BLACK, HEAD)
    # Eyes looking out, a little to the left.
    figure.pixels([(7, 19), (7, 20), (8, 19), (17, 19), (17, 20), (18, 19)], BLACK, HEAD)
    # Nose.
    figure.pixels([(5, 21), (4, 22), (4, 23), (5, 24), (6, 24)], BLACK, HEAD)
    # Mouth through the beard, and a few lighter hairs in it.
    figure.pixels([(6, 27), (7, 27), (8, 27), (9, 27), (10, 27), (7, 28), (8, 28)], WHITE, HEAD)
    figure.pixels([(11, 29), (14, 31), (17, 31), (20, 31), (23, 29), (26, 27), (9, 31), (15, 33),
                   (22, 32), (28, 25)], WHITE, HEAD)
    # Inside of the ear.
    figure.pixels([(29, 20), (29, 21), (29, 22), (28, 23)], BLACK, HEAD)
    # Crew-neck collar.
    figure.row(39, 42, 58, WHITE, over=BLACK)
    # A crease at each elbow and the knuckles of the hand on the bicep.
    figure.pixels([(34, 49), (34, 51), (36, 48)], BLACK)
    # Belt and knee creases on the jeans.
    figure.row(74, 34, 67, WHITE, over=BLACK)
    figure.pixels([(37, 98), (38, 98), (39, 98), (60, 98), (61, 98), (62, 98)], WHITE)
    # Laces and soles on the trainers.
    figure.pixels([(34, 114), (36, 115), (38, 114), (61, 114), (63, 115), (65, 114)], BLACK)
    for x in range(28, 72):
        if figure.out[119][x] == WHITE and figure.out[120][x] == WHITE:
            figure.set(x, 119, BLACK)


if __name__ == '__main__':
    rafi = Figure(PARTS, SAME)
    details(rafi)
    rafi.save(OUT, PREVIEW)
