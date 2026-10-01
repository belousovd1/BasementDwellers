extends Node2D
## The player's attack: an indicator sweeps back and forth across the bar and
## the player presses accept to stop it. The closer to the centre, the more
## damage the hit does.

## Emitted once, when the player stops the indicator.
signal struck(damage: int)

const MAX_DAMAGE := 100
## Indicator distance from the centre at which the damage reaches zero.
const ZERO_DAMAGE_DISTANCE := 1030.0

## Uses the faster sweep from the final stage.
@export var fast := false

var _struck := false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _indicator: Sprite2D = $Indicator


func _ready() -> void:
	_animation_player.play("stage3run" if fast else "Run")


func _process(_delta: float) -> void:
	if not _struck and Input.is_action_pressed("ui_accept"):
		_struck = true
		_animation_player.pause()
		struck.emit(get_damage())


func get_damage() -> int:
	var off_centre := absf(_indicator.position.x)
	return roundi((1.0 - off_centre / ZERO_DAMAGE_DISTANCE) * MAX_DAMAGE)
