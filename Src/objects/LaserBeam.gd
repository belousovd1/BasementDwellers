extends Node2D


# Declare member variables here. Examples:
const max_length = 2000

onready var ray_cast = $RayCast2D
var damage = 20
signal laser_fired

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	check_if_hit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func end_laser_animation():
	self.connect("laser_fired", get_node("../../../"), "stop_attacking")
	emit_signal("laser_fired")

func check_if_hit():
	var player_hit
	var player = $"../../../../../Player"
	var object = ray_cast.get_collider()
	if player == null and object == null:
		player_hit = false
	if player_hit and object == player:
		object._on_ProjectileDetector_area_entered(self)
