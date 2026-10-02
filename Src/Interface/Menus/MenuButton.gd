@tool
extends Button
## A flat menu button drawn by its Label child, which carries the green drop
## shadow. The label turns yellow while the mouse is over the button.

const HOVER_COLOR := Color(0.92, 0.94, 0.27)

@export var label := "Button":
	set(value):
		label = value
		if is_node_ready():
			_label.text = value

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = label
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_set_highlighted.bind(true))
	mouse_exited.connect(_set_highlighted.bind(false))


func _set_highlighted(highlighted: bool) -> void:
	_label.self_modulate = HOVER_COLOR if highlighted else Color.WHITE
