extends Sprite
var time = 0
onready var n = (get_material().get_shader_param("noise") as NoiseTexture)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * 75
	var offset = n.noise.get_noise_1d(time)
	$Light2D.scale = Vector2(2 + offset/2, 2 + offset/2)
