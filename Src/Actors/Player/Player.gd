extends CharacterBody2D
## The heart the player steers around the arena.

## Emitted after every hit that gets through, with the remaining health.
signal hit(health: int)
signal died
## Emitted by the death animation when it ends.
signal death_animation_finished

@export var speed := 500.0
@export var max_health := 100

var health: int
var alive := true
var invincible := false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _invincibility_timer: Timer = $InvTimer


func _ready() -> void:
	health = max_health


func _physics_process(_delta: float) -> void:
	if alive:
		velocity = Input.get_vector("left", "right", "up", "down") * speed
		move_and_slide()


## Damages the player, unless they are still invincible from the last hit or
## hidden (the arena is put away during the player's turn and dialogue).
func take_hit(damage: int) -> void:
	if invincible or not alive or not is_visible_in_tree():
		return
	health = maxi(health - damage, 0)
	if health == 0:
		_die()
	else:
		_animation_player.play("Hit")
	invincible = true
	_invincibility_timer.start()
	hit.emit(health)


func _die() -> void:
	alive = false
	died.emit()
	_animation_player.play("death")


func _on_ProjectileDetector_area_entered(area: Area2D) -> void:
	take_hit(area.damage)


func _on_InvTimer_timeout() -> void:
	invincible = false


# Called from the end of the "death" animation.
func _on_death_animation_finished() -> void:
	death_animation_finished.emit()
