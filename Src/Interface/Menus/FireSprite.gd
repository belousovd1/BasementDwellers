extends Sprite2D
## The trash-can fire. Its light flickers using the same noise that drives the
## flame shader.

const FLICKER_SPEED := 75.0

var _time := 0.0

@onready var _noise: Noise = (material.get_shader_parameter("noise") as NoiseTexture2D).noise
@onready var _light: PointLight2D = $PointLight2D


func _process(delta: float) -> void:
	_time += delta * FLICKER_SPEED
	var flicker := _noise.get_noise_1d(_time)
	_light.scale = Vector2.ONE * (2.0 + flicker / 2.0)
