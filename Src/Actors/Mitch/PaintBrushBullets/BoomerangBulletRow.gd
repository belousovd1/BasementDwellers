extends Node2D
## Three paintbrushes travelling side by side. [member gap_index] removes one of
## them to leave a gap for the player to dodge through.

@export var speed := 200.0
## Which paintbrush (0-2) to remove, or -1 to keep all three.
@export var gap_index := -1

var direction := Vector2.ZERO


func _ready() -> void:
	if gap_index >= 0:
		get_child(gap_index).queue_free()


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	# The paintbrushes free themselves off-screen; drop the empty row too.
	if get_child_count() == 0:
		queue_free()
