class_name WarningZone
extends Projectile
## A rectangle that warns the player for [member warn_time] seconds, then hurts
## them for [member active_time] seconds and frees itself. Subclasses draw it,
## using [method is_active] and [method phase_progress].

## Size of the rectangle in pixels, centred on the zone's position.
@export var size := Vector2(100, 100)
@export var warn_time := 0.8
@export var active_time := 0.3

var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	(_hitbox.shape as RectangleShape2D).size = size
	_hitbox.disabled = true


func _process(delta: float) -> void:
	var was_active := is_active()
	_time += delta
	if is_active() and not was_active:
		_hitbox.disabled = false
		_sound.play()
	if _time >= warn_time + active_time:
		queue_free()
	queue_redraw()


## Whether the warning is over and the zone hurts.
func is_active() -> bool:
	return _time >= warn_time


## How far through the warning, or through the active time, the zone is (0 to 1).
func phase_progress() -> float:
	if is_active():
		return clampf((_time - warn_time) / active_time, 0, 1)
	return _time / warn_time
