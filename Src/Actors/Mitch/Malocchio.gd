extends Node2D


# Declare member variables here. Examples:
# var a = 2
var damage = 20
signal attacking

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_attacking():
	emit_signal("attacking")
