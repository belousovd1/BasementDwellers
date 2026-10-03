extends Node2D
## A musical staff across the arena: five lines and a treble clef. It fades in,
## stays for [member duration] seconds and fades away. It doesn't hurt by
## itself; it shows the lines that notes will slide along.

## Heights of the five lines, top to bottom, in arena space.
const LINES: Array[float] = [-160, -80, 0, 80, 160]
const CLEF: Array[String] = [
	"    ##  ",
	"   #  # ",
	"   #  # ",
	"   # #  ",
	"   ##   ",
	"  ##    ",
	" # #    ",
	"#  ###  ",
	"# # # # ",
	"#  #  # ",
	" # #  # ",
	"  ####  ",
	"   #    ",
	" # #    ",
	"  #     ",
]
const FADE_TIME := 0.4

## Half the staff's length, in pixels.
@export var half_length := 304.0
@export var duration := 4.0

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time > duration + FADE_TIME:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var fade := clampf(minf(_time, duration + FADE_TIME - _time) / FADE_TIME, 0, 1)
	var color := Color(PixelArt.GREY, fade)
	for y in LINES:
		PixelArt.line(self, Vector2(-half_length, y), Vector2(half_length, y), color, 1, 4)
	var clef_size := PixelArt.bitmap_size(CLEF)
	PixelArt.bitmap(self, CLEF, Vector2(-half_length - clef_size.x - PixelArt.SIZE, -clef_size.y / 2),
			{"#": Color(PixelArt.WHITE, fade)})
