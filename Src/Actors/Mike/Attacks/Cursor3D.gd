extends Node2D
## Blender's 3D cursor: a red and white ring with crosshairs. It drifts towards
## [member target], and while it is locked it stops and blinks, marking where
## the next cube will be added. It doesn't hurt by itself.

## Radius of the ring, in art pixels.
const RADIUS := 6
const RED := Color("e83030")
## Seconds the cursor is shown, then hidden, while it blinks.
const BLINK := 0.08

@export var speed := 160.0

## Where the cursor drifts towards, in its parent's coordinates.
var target := Vector2.ZERO
var _locked := false
var _time := 0.0

@onready var _lock_sound: AudioStreamPlayer = $LockSound


func _process(delta: float) -> void:
	_time += delta
	if not _locked:
		position = position.move_toward(target, speed * delta)
	queue_redraw()


## Stops the cursor where it is and starts it blinking.
func lock() -> void:
	_locked = true
	_time = 0.0
	_lock_sound.play()


func unlock() -> void:
	_locked = false


func _draw() -> void:
	if _locked and fmod(_time, BLINK * 2) >= BLINK:
		return
	var radius := RADIUS * PixelArt.SIZE
	# The ring alternates red and white in eight dashes.
	var steps := RADIUS * 8
	for i in steps:
		var color := RED if (i * 8 / steps) % 2 == 0 else PixelArt.WHITE
		PixelArt.dot(self, Vector2.from_angle(TAU * i / steps) * radius, color)
	# Crosshairs cross the ring, leaving the middle clear.
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		PixelArt.line(self, direction * (radius - 2 * PixelArt.SIZE),
				direction * (radius + 3 * PixelArt.SIZE), PixelArt.WHITE)
