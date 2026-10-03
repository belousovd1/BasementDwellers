extends Projectile
## A face extruded out of an arena wall. The face blinks on the wall, then
## shoots [member depth] pixels into the arena, holds there and pulls back.
## It grows along its local y axis, so rotate it to point into the arena.

const OUT_TIME := 0.12
const BACK_TIME := 0.35

## Width of the face along the wall, in pixels.
@export var width := 140.0
## How far it reaches into the arena, in pixels.
@export var depth := 300.0
@export var warn_time := 0.7
@export var hold_time := 0.5

var _extent := 0.0
var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	_hitbox.disabled = true
	var tween := create_tween()
	tween.tween_interval(warn_time)
	tween.tween_callback(_sound.play)
	tween.tween_property(self, "_extent", depth, OUT_TIME) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold_time)
	tween.tween_property(self, "_extent", 0.0, BACK_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_time += delta
	var rect := _hitbox.shape as RectangleShape2D
	rect.size = Vector2(width, _extent)
	_hitbox.position.y = _extent / 2
	_hitbox.disabled = _extent < PixelArt.SIZE
	queue_redraw()


func _draw() -> void:
	if _extent < PixelArt.SIZE:
		# The selected face, waiting on the wall.
		if fmod(_time, 0.2) < 0.1:
			PixelArt.line(self, Vector2(-width / 2, 0), Vector2(width / 2, 0), PixelArt.ORANGE, 2)
		return
	var block := Rect2(-width / 2, 0, width, _extent)
	PixelArt.fill(self, block, PixelArt.BLACK)
	PixelArt.outline(self, block, PixelArt.WHITE)
	# The extruded face stays selected at the tip.
	var tip := Vector2(0, _extent - PixelArt.SIZE / 2)
	PixelArt.line(self, tip - Vector2(width / 2, 0), tip + Vector2(width / 2, 0), PixelArt.ORANGE, 2)
