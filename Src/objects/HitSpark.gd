extends Node2D
## The strike where the player's attack lands on a boss: a white lightning
## slash. A ring snaps on with a thin slice through it, then a thick zigzag bolt
## cracks along the slice, flickers once into a new zigzag, thins to a line and
## goes, throwing off a few sparks. Its thick frames are edged in black, so it
## still reads over the white parts of a boss.
##
## Each boss's "hit" animation drives it through [member frame], from
## [constant FIRST_FRAME] to [constant LAST_FRAME], and shows and hides it.

const FIRST_FRAME := 2
const LAST_FRAME := 15
## The slash runs from bottom left to top right, at this angle.
const ANGLE := -0.6
## Sparks thrown off at the end.
const SPARKS := 6
## Per frame from FIRST_FRAME: the ring's radius (0 for none), the bolt's width
## in art pixels (0 for none), and how far the sparks have flown. The bolt
## flickers into a new zigzag on FLICKER_STEP.
const RING: Array[int] = [28, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
const BOLT: Array[int] = [0, 3, 4, 3, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0]
const SPARK_DISTANCE: Array[int] = [0, 0, 0, 0, 10, 18, 24, 28, 31, 0, 0, 0, 0, 0]
const FLICKER_STEP := 3

## Frame of the hit; anything outside FIRST_FRAME to LAST_FRAME draws nothing.
@export var frame := 0:
	set(value):
		if value == FIRST_FRAME and frame != FIRST_FRAME or value == FIRST_FRAME + FLICKER_STEP:
			_zigzag()
		if value == FIRST_FRAME and frame != FIRST_FRAME:
			_scatter_sparks()
		frame = value
		queue_redraw()
## Half the length of the slash, in art pixels.
@export var reach := 50

var _bolt: Array[Vector2] = []
var _sparks: Array[Vector2] = []


func _ready() -> void:
	_zigzag()
	_scatter_sparks()


func _draw() -> void:
	if frame < FIRST_FRAME or frame > LAST_FRAME:
		return
	var step := frame - FIRST_FRAME
	var pixel := PixelArt.SIZE
	var along := Vector2.from_angle(ANGLE) * reach * pixel

	if RING[step] > 0:
		var radius := RING[step] * pixel
		var dots := RING[step] * 6
		for i in dots:
			PixelArt.dot(self, Vector2.from_angle(TAU * i / dots) * radius, PixelArt.WHITE, 2)
		PixelArt.line(self, -along, along, PixelArt.WHITE)

	var width := BOLT[step]
	if width > 0:
		for i in _bolt.size() - 1:
			if width > 1:
				PixelArt.line(self, _bolt[i] * pixel, _bolt[i + 1] * pixel, PixelArt.BLACK, width + 2)
		for i in _bolt.size() - 1:
			PixelArt.line(self, _bolt[i] * pixel, _bolt[i + 1] * pixel, PixelArt.WHITE, width)

	if SPARK_DISTANCE[step] > 0:
		for spark in _sparks:
			PixelArt.dot(self, spark * SPARK_DISTANCE[step] * pixel, PixelArt.WHITE, 2 if step < 7 else 1)


## A new zigzag for the bolt, shaped like a lightning bolt: long strokes
## roughly along the slash, each broken by a short, sharp kink back across it.
func _zigzag() -> void:
	var along := Vector2.from_angle(ANGLE)
	var end := along * reach
	var point := -end
	var kink_side := 1.0 if randf() < 0.5 else -1.0
	_bolt = [point]
	while (end - point).dot(along) > 18:
		point += along.rotated(randf_range(-0.2, 0.2)) * randf_range(16.0, 24.0)
		_bolt.append(point)
		# No kink right before the tip, so the bolt ends in a straight stroke.
		if (end - point).dot(along) <= 18:
			break
		point += along.rotated(kink_side * randf_range(1.9, 2.3)) * randf_range(4.0, 7.0)
		_bolt.append(point)
		kink_side = -kink_side
	# Finish straight along the slash, wherever the strokes have drifted to.
	_bolt.append(point + along * maxf((end - point).dot(along), 0.0))


func _scatter_sparks() -> void:
	_sparks.clear()
	for i in SPARKS:
		_sparks.append(Vector2.from_angle(TAU * i / SPARKS + randf_range(-0.3, 0.3)) * randf_range(0.8, 1.2))
