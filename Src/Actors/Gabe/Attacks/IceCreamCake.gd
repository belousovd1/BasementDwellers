extends Node2D
## A whole ice cream cake against an arena wall that shoots slices of itself
## into the arena. It jiggles for [member warn_time] seconds, its candles
## flickering, while dashed lines mark how wide it will fire, then shoots
## slices for [member spray_time] seconds in a fan that sweeps to one side and
## back, kicking with every shot, and frees itself. The cake doesn't hurt; the
## slices do.

const CakeSliceScene := preload("res://Src/Actors/Gabe/Attacks/CakeSlice.tscn")
## The cake, a row of pixels per string, centred on the node.
const SHAPE: Array[String] = [
	"      #      #      ",
	"     #F#    #F#     ",
	"     #k#    #k#     ",
	"     #k#    #k#     ",
	"  ## #k######k# ##  ",
	" #wr#w##wrrw##w#rw# ",
	" #wwwwwwwwwwwwwwww# ",
	"#wwwwwwwwwwwwwwwwww#",
	"#ffffffffffffffffff#",
	"#pppPpppppppppppppp#",
	"#pppppppppppPpppppp#",
	"#vvvvvvvvvvvvvvPvvv#",
	"#vvvvvvPvvvvvvvvvvv#",
	"#bbbbbbbbbbbbbbbbbb#",
	" ################## ",
]
## The colours of the cake, as for a slice (see CakeSlice.gd), plus
## F candle flames and k candles.
const PALETTE := {
	"#": Color.WHITE, "r": Color("dc1e32"), "w": Color("faf8f0"), "f": Color("5a321e"),
	"p": Color("ff96b4"), "P": Color("c8285a"), "v": Color("fff0c8"), "b": Color("8c5f37"),
	"F": Color("ffc83c"), "k": Color("78b4ff"),
}
const FLICKER := Color("ff7a2a")
## How far the dashed lines reach into the arena during the warning.
const GUIDE_LENGTH := 260.0
## Seconds it kicks back after each shot.
const KICK_TIME := 0.06

## The way the slices fly: into the arena, away from the wall.
@export var direction := Vector2.DOWN
## How far the fan swings either side of [member direction], in radians.
@export var sweep := 0.8
@export var warn_time := 0.9
@export var spray_time := 3.0
## Slices shot per second, and how fast they leave the cake.
@export var rate := 6.0
@export var slice_speed := 380.0

var _time := 0.0
var _owed := 0.0
var _kick := 0.0

@onready var _shot_sound: AudioStreamPlayer = $ShotSound


func _process(delta: float) -> void:
	_time += delta
	_kick = maxf(_kick - delta, 0.0)
	queue_redraw()
	if _time < warn_time:
		return
	if _time >= warn_time + spray_time:
		queue_free()
		return
	_owed += rate * delta
	while _owed >= 1.0:
		_owed -= 1.0
		_shoot()


func _shoot() -> void:
	var progress := (_time - warn_time) / spray_time
	var angle := direction.angle() + sin(progress * TAU) * sweep + randf_range(-0.08, 0.08)
	var slice := CakeSliceScene.instantiate()
	slice.position = position + Vector2.from_angle(angle) * PixelArt.bitmap_size(SHAPE).x / 2
	slice.direction = Vector2.from_angle(angle)
	slice.speed = slice_speed * randf_range(0.9, 1.1)
	get_parent().add_child(slice)
	_kick = KICK_TIME
	_shot_sound.play()


func _draw() -> void:
	var warning := _time < warn_time
	if warning and fmod(_time, 0.2) < 0.12:
		for side in [-1.0, 1.0]:
			var edge: Vector2 = direction.rotated(sweep * side).normalized() * GUIDE_LENGTH
			PixelArt.line(self, Vector2.ZERO, edge, PixelArt.YELLOW, 1, 2)
	var corner := -PixelArt.bitmap_size(SHAPE) / 2
	if warning:
		# Jiggling as it gets ready.
		corner.x += roundf(sin(_time * 40.0)) * PixelArt.SIZE
	elif _kick > 0.0:
		# Knocked back from the shot.
		corner -= direction.normalized().round() * PixelArt.SIZE
	var palette := PALETTE.duplicate()
	if fmod(_time, 0.16) < 0.08:
		palette["F"] = FLICKER
	PixelArt.bitmap(self, SHAPE, corner, palette)
