
extends PanelContainer

onready var back = get_node("../TextBackground")


func _input(event):
	if (event is InputEventKey) or (event is InputEventMouse):
		$Label.text = "SPACE"
	elif (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		$Label.text = "B"


func _process(delta):
	self.rect_position.x = (back.rect_position.x + back.rect_size.x) - (self.rect_size.x)
	self.rect_position.y = (back.rect_position.y + back.rect_size.y) - (self.rect_size.y / 4)
