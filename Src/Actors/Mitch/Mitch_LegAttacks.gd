extends Node2D
## Mitch's legs kicking in from both sides of the arena.

## Plays the faster kick pattern used at the end of stage 2.
@export var advanced := false


func _ready() -> void:
	$AnimationPlayer.play("Adv Alternating kicks" if advanced else "AlternatingKicks")
