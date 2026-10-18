extends Projectile
## One of Mitch's kidney stones, dropped on the player. A pale shadow grows
## where it will land, blinking just before, while the stone tumbles down from
## above the screen, speeding up;
## it lands with a crunch and a puff of dust, sits there hurting anyone who
## touches it, then fades away. With [member shatter] it bursts into shards
## as it lands. Top-level, positioned on the screen.

const KidneyShardScene := preload("res://Src/Actors/Mitch/Attacks/KidneyShard.tscn")
## The stone, a row of pixels per string, centred on where it lands.
const SHAPE: Array[String] = [
	"     #   #     ",
	"    #h# #y#    ",
	"  ##hhh#yy###  ",
	" #hhhhyyyyyyy# ",
	"##hhdyyyyydyy##",
	"#hhyyyyyyyyyyo#",
	" #yydyyyyyyoo# ",
	"##yyyyyydyoooo#",
	"#yyyyyyyyyooo# ",
	" #yyydyyyooo#  ",
	"  #yyyyyooo##  ",
	"   ##yy#oo#    ",
	"     ## ##     ",
]
## In black and white: # outline, y the stone, h where it catches the light,
## o its shadowed side and d the pits in it.
const PALETTE := {
	"#": Color.WHITE, "y": Color(0.72, 0.72, 0.74), "h": Color.WHITE, "o": PixelArt.GREY, "d": Color.BLACK,
}
## The shadow, pale so it shows up on the black floor, and its rim.
const SHADOW := Color(0.72, 0.72, 0.74)
const RIM := Color.WHITE
const DUST := Color(0.8, 0.8, 0.82)
## How far above its landing spot it starts falling.
const FALL_HEIGHT := 900.0
## Half the shadow's width and height when the stone lands, in art pixels.
const SHADOW_SIZE := Vector2(8, 3)
const DUST_TIME := 0.3
const FADE_TIME := 0.2
const SHARDS := 6
const SHARD_SPEED := 340.0

## Seconds from appearing to landing, and how long it then sits there.
@export var warn_time := 1.0
@export var rest_time := 0.5
## Whether it bursts into shards when it lands.
@export var shatter := false

var _time := 0.0
var _landed := false

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _crunch: AudioStreamPlayer = $Crunch


func _ready() -> void:
	_hitbox.disabled = true


func _process(delta: float) -> void:
	_time += delta
	if _time >= warn_time and not _landed:
		_land()
	if _time >= warn_time + rest_time + FADE_TIME:
		queue_free()
		return
	if _time >= warn_time + rest_time:
		modulate.a = 1.0 - (_time - warn_time - rest_time) / FADE_TIME
	queue_redraw()


func _land() -> void:
	_landed = true
	_hitbox.disabled = false
	_crunch.play()
	if not shatter:
		return
	for i in SHARDS:
		var shard := KidneyShardScene.instantiate()
		shard.top_level = true
		shard.position = global_position
		var angle := TAU * i / SHARDS + randf_range(-0.3, 0.3)
		shard.velocity = Vector2.from_angle(angle) * SHARD_SPEED * randf_range(0.8, 1.2)
		get_parent().add_child(shard)


func _draw() -> void:
	var size := PixelArt.bitmap_size(SHAPE)
	if not _landed:
		var falling := _time / warn_time
		_draw_shadow(falling)
		# Tumbling down, faster and faster.
		var height := FALL_HEIGHT * (1.0 - falling * falling)
		PixelArt.bitmap(self, SHAPE, -size / 2 - Vector2(0, height), PALETTE, fmod(_time, 0.2) < 0.1)
		return
	var since := _time - warn_time
	var corner := -size / 2
	if since < 0.08:
		# Squashed into the floor for a moment.
		corner.y += PixelArt.SIZE
	_draw_shadow(1.0)
	PixelArt.bitmap(self, SHAPE, corner, PALETTE)
	if since < DUST_TIME:
		_draw_dust(since / DUST_TIME)


## The shadow on the floor where it will land, growing and brightening as it
## falls ([param falling] from 0 to 1), its rim blinking near the end.
func _draw_shadow(falling: float) -> void:
	var radius := SHADOW_SIZE * (0.3 + 0.7 * falling)
	var fill := Color(SHADOW, 0.15 + 0.3 * falling)
	var rim_on := falling < 0.6 or fmod(_time, 0.12) < 0.06 or _landed
	var rim := Color(RIM, 0.4 + 0.6 * falling)
	var below := Vector2(0, PixelArt.bitmap_size(SHAPE).y / 2 - PixelArt.SIZE)
	for y in range(-ceili(radius.y), ceili(radius.y) + 1):
		for x in range(-ceili(radius.x), ceili(radius.x) + 1):
			var distance := pow(x / radius.x, 2) + pow(y / radius.y, 2)
			if distance > 1.0:
				continue
			# The outermost ring of pixels is the rim.
			var edge := pow((absf(x) + 1) / radius.x, 2) + pow(y / radius.y, 2) > 1.0 \
					or pow(x / radius.x, 2) + pow((absf(y) + 1) / radius.y, 2) > 1.0
			if edge and rim_on and not _landed:
				PixelArt.dot(self, below + Vector2(x, y) * PixelArt.SIZE, rim)
			else:
				PixelArt.dot(self, below + Vector2(x, y) * PixelArt.SIZE, fill)


## Puffs of dust thrown out sideways as it lands ([param spread] from 0 to 1).
func _draw_dust(spread: float) -> void:
	var below := Vector2(0, PixelArt.bitmap_size(SHAPE).y / 2)
	var color := Color(DUST, 1.0 - spread)
	for side in [-1.0, 1.0]:
		for i in 3:
			var out := Vector2(side * (8 + i * 4) * (0.5 + spread), -i * 2 - spread * 4) * PixelArt.SIZE / 2
			PixelArt.dot(self, below + out, color, 2 if i == 0 else 1)
