class_name Mike
extends Boss
## The second boss: a meditating 3D artist who fights with Blender. For his
## final stage he gets Blender's orange outline for the selected object. His
## stages, dialogue and banter are set on Mike.tscn.

const OutlineShader := preload("res://Assets/Shaders/SelectionOutline.gdshader")

@onready var _body: Sprite2D = $Parts/Body
@onready var _power_up_sound: AudioStreamPlayer = $PowerUpSound


## Outlines Mike like Blender's selected object.
func power_up() -> void:
	if _body.material:
		return
	var outline := ShaderMaterial.new()
	outline.shader = OutlineShader
	_body.material = outline
	_power_up_sound.play()
