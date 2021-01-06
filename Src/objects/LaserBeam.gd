extends Node2D


# Declare member variables here. Examples:
const max_length = 2000

onready var ray_cast = $RayCast2D
var damage = 20
signal laser_fired

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = self.connect("laser_fired", get_node("../../../"), "stop_attacking")

func _process(_delta):
	pass
	#check_if_hit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func end_laser_animation():
	emit_signal("laser_fired")

func check_if_hit():
	var player_hit
	var player = $"../../../../../Player"
	var object = ray_cast.get_collider()
	print(object)
	if player == null and object == null:
		print("no hit ")
		player_hit = false
	if object == player:
		print("hit")
		object._on_ProjectileDetector_area_entered(self)
