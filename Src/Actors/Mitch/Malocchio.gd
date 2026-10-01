extends Node2D
## Mitch's floating eye. On its own it plays the summoning animation, which
## frees it at the end; inside MalocchioPath it flies around firing [member laser].

@onready var laser: Node2D = $LaserBeam
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func summon() -> void:
	animation_player.play("summon")
