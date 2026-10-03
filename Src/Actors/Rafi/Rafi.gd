class_name Rafi
extends Boss
## The fourth boss: arms crossed, unimpressed, and he has seen every move the
## other bosses have. For his final stage he gets a red outline. His stages,
## dialogue and banter are set on Rafi.tscn.
##
## His fight is a placeholder until he gets a theme of his own: his stages
## borrow Mike's and Gabe's attacks.

const OutlineShader := preload("res://Assets/Shaders/SelectionOutline.gdshader")
const OUTLINE_COLOR := Color("e83030")

@onready var _body: Sprite2D = $Parts/Body
@onready var _power_up_sound: AudioStreamPlayer = $PowerUpSound


## Outlines Rafi in red.
func power_up() -> void:
	if _body.material:
		return
	var outline := ShaderMaterial.new()
	outline.shader = OutlineShader
	outline.set_shader_parameter("outline_color", OUTLINE_COLOR)
	_body.material = outline
	_power_up_sound.play()
