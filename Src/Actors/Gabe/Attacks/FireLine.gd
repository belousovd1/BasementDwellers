extends Node2D
## The warning before a burst of apples: a red line of fire down the path they
## will take, blinking faster and faster, then flashing white just before they
## fly. It doesn't hurt, and frees itself after [member warn_time] seconds.

const BEAM := Color(1.0, 0.2, 0.15, 0.16)
const RED := Color("ff3c3c")
## Seconds the line flashes white at the end.
const FLASH_TIME := 0.12
## Seconds per blink at the start and at the end.
const SLOW_BLINK := 0.24
const FAST_BLINK := 0.06

## The way the apples will fly, and how far the line reaches.
@export var direction := Vector2.DOWN
@export var length := 1200.0
## How wide the line of fire is, in pixels: about an apple across.
@export var width := 44.0
@export var warn_time := 0.8

var _time := 0.0
var _blink := 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time >= warn_time:
		queue_free()
		return
	# Blink faster as the burst gets closer.
	_blink += delta / lerpf(SLOW_BLINK, FAST_BLINK, _time / warn_time)
	queue_redraw()


func _draw() -> void:
	var along := direction.normalized() * length
	var side := direction.normalized().orthogonal() * width / 2
	if _time >= warn_time - FLASH_TIME:
		PixelArt.line(self, Vector2.ZERO, along, PixelArt.WHITE, 3)
		return
	if fmod(_blink, 1.0) >= 0.5:
		return
	draw_colored_polygon(PackedVector2Array([side, along + side, along - side, -side]), BEAM)
	PixelArt.line(self, side, along + side, RED, 1, 3)
	PixelArt.line(self, -side, along - side, RED, 1, 3)
	PixelArt.line(self, Vector2.ZERO, along, RED, 1, 1)
