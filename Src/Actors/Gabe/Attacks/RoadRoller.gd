extends Projectile
## A road roller dropped from the sky. Its shadow grows where it will land, then
## it falls, slams down and hurts while it sits there, and finally fades away.

## The roller, a row of pixels per string: # outline, y paint, w the drum and
## k the dark parts.
const SHAPE: Array[String] = [
	"                  ############",
	"                 #yyyyyyyyyyyy#",
	"   ############## #k########k#",
	"  #yyyyyyyyyyyyyy##k#      #k#  #",
	"  #yyyyyyyyyyyyyy##k#      #k# #k#",
	"   ####wwwww#yyyy##k# #### #k# #k#",
	"    #wwwwwwwwyyyy##k##kkkk##k# #k##",
	"   #wwwwwwwwwyyyy##k##kkkk##k##yyyy#",
	"  #wwwwwwwwwwyyyy##k##kkkk##k##yyyy#",
	"  #wwwwwwwwwwyyyyyyyyyyyyyyyyyyyyyy#",
	" #wwwwwwwkwwwwwwwyyyyyyyyyyyyyyyyyy#",
	" #wwwwwwkkkwwwwwwyyyyyyyyyyyyyyyyyy#",
	" #wwwwwkkkkkwwwwwyyyyyyyyykkkkkyyyy#",
	" #wwwwwwkkkwwwwwwyyyyyyyykkkkkkkyyy#",
	" #wwwwwwwkwwwwwwwyyyyyyykkkkwkkkkyy#",
	"  #wwwwwwwwwwwwwyyyyyyyykkkwwwkkkyy#",
	"  #wwwwwwwwwwwww########kkkwwwkkk##",
	"   #wwwwwwwwwww#       #kkkkwkkkk#",
	"    #wwwwwwwww#         #kkkkkkk#",
	"     ##wwwww##           #kkkkk#",
	"       #####              #####",
]
const PAINT := Color("f7d13c")
const DRUM := Color("8f97a6")
const DARK := Color(0.08, 0.08, 0.1)
const SHADOW := Color(0.3, 0.3, 0.38)
## How long the fall takes, from how high it starts, and how long it takes to
## fade once it has done its damage.
const FALL_TIME := 0.2
const FALL_HEIGHT := 900.0
const FADE_TIME := 0.3

## Seconds the shadow warns before the roller lands, and that it sits there.
@export var warn_time := 1.0
@export var hold_time := 0.6

var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _impact_sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	(_hitbox.shape as RectangleShape2D).size = PixelArt.bitmap_size(SHAPE) - Vector2(16, 24)
	_hitbox.position.y = 8
	_hitbox.disabled = true


func _process(delta: float) -> void:
	var was_landed := _time >= warn_time
	_time += delta
	if _time >= warn_time and not was_landed:
		_hitbox.disabled = false
		_impact_sound.play()
	if _time >= warn_time + hold_time:
		_hitbox.disabled = true
	if _time >= warn_time + hold_time + FADE_TIME:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var size := PixelArt.bitmap_size(SHAPE)
	var fade := 1.0 - clampf((_time - warn_time - hold_time) / FADE_TIME, 0, 1)
	# The shadow grows as the roller nears the ground.
	var growth := clampf(_time / warn_time, 0, 1)
	var shadow := Vector2(size.x * 0.55, size.y * 0.22) * (0.3 + 0.7 * growth)
	var cells := (shadow / PixelArt.SIZE).ceil()
	var feet := Vector2(0, size.y / 2 - PixelArt.SIZE * 2)
	for y in range(-cells.y, cells.y + 1):
		for x in range(-cells.x, cells.x + 1):
			var at := Vector2(x, y) * PixelArt.SIZE
			if (at.x / shadow.x) ** 2 + (at.y / shadow.y) ** 2 <= 1:
				PixelArt.dot(self, feet + at, Color(SHADOW, fade))
	# The roller itself falls in over the last moments of the warning.
	var drop := clampf((warn_time - _time) / FALL_TIME, 0, 1)
	if drop >= 1:
		return
	var palette := {"#": Color(PixelArt.WHITE, fade), "y": Color(PAINT, fade), "w": Color(DRUM, fade),
			"k": Color(DARK, fade)}
	PixelArt.bitmap(self, SHAPE, -size / 2 - Vector2(0, FALL_HEIGHT * drop * drop), palette)
