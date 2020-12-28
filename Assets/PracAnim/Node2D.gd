extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print($Malocchio.get_global_transform_with_canvas().origin)
	var t = $Malocchio.get_global_transform_with_canvas().origin
	t.x = clamp(t.x, 0 , get_viewport_rect().size.x) / get_viewport_rect().size.x
	t.y = clamp(t.y, 0 , get_viewport_rect().size.y) / get_viewport_rect().size.y
	$CanvasLayer/ColorRect.get_material().set_shader_param("center", t)
	print(t)
	print($CanvasLayer/ColorRect.get_material().get_shader_param("center"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
