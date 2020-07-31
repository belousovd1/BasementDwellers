extends Camera2D


# Declare member variables here. Examples:
export (OpenSimplexNoise) var noise
export (float, 0, 1) var trauma = 0.0


export var max_x = 10
export var max_y = 10

var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	time += delta

	var shake = pow(trauma, 2)
	offset.x = noise.get_noise_3d(time * 400, 0, 0) * max_x * shake
	offset.y = noise.get_noise_3d(0, time * 400, 0) * max_y * shake
	
	

