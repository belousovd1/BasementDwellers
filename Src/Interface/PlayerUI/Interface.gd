extends Control
## The player's health counter and bar. Both animate to each new value.

const ANIMATION_TIME := 0.6

var _tween: Tween

@onready var _count: Label = $HealthBar/Counter/Count
@onready var _bar: TextureProgressBar = $HealthBar/TextureProgressBar


func set_max_health(value: int) -> void:
	_bar.max_value = value
	show_health(value)


func show_health(value: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_display, _bar.value, float(value), ANIMATION_TIME)


func _display(value: float) -> void:
	_count.text = str(roundi(value))
	_bar.value = value
