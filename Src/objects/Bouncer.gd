class_name Bouncer
extends Projectile
## A round projectile that bounces around [member bounds] off the arena walls,
## like Gabe's tyres and Alex's records. It blinks in place harmlessly for
## [constant APPEAR_TIME] seconds before it sets off. Subclasses draw it, using
## [method is_blinked_out], and can follow its movement in [method _moved].
##
## The scene needs a CollisionShape2D and a Sound, played on every bounce.

const APPEAR_TIME := 0.7

@export var speed := 220.0
## Its radius in pixels, for bouncing off the walls.
@export var radius := 32.0

## The rectangle it bounces around inside, in its parent's coordinates.
var bounds := Rect2()
var direction := Vector2.ONE
var _velocity := Vector2.ZERO
var _time := 0.0

@onready var _hitbox: CollisionShape2D = $CollisionShape2D
@onready var _bounce_sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	_hitbox.disabled = true


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _time < APPEAR_TIME:
		return
	if _hitbox.disabled:
		_hitbox.disabled = false
		_velocity = direction.normalized() * speed
	position += _velocity * delta
	_moved(delta)
	_bounce_off_walls()


## Bounces faster from now on.
func speed_up(factor: float) -> void:
	speed *= factor
	_velocity *= factor


## Whether it is in the hidden half of a blink while it appears.
func is_blinked_out() -> bool:
	return _time < APPEAR_TIME and fmod(_time, 0.14) >= 0.07


## Called every frame once it is moving, after it has moved.
func _moved(_delta: float) -> void:
	pass


func _bounce_off_walls() -> void:
	var bounced := false
	if position.x - radius < bounds.position.x and _velocity.x < 0 \
			or position.x + radius > bounds.end.x and _velocity.x > 0:
		_velocity.x = -_velocity.x
		bounced = true
	if position.y - radius < bounds.position.y and _velocity.y < 0 \
			or position.y + radius > bounds.end.y and _velocity.y > 0:
		_velocity.y = -_velocity.y
		bounced = true
	if bounced:
		_bounce_sound.play()
