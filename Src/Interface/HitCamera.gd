extends Camera2D
## Screen shake for when the player is hit. [method shake] takes over the view
## for [member duration] seconds and jitters it with noise.

@export var noise: FastNoiseLite
## Shake strength from 0 to 1; squared before use.
@export_range(0.0, 1.0) var trauma := 0.0
@export var max_x := 10.0
@export var max_y := 10.0
@export var duration := 0.5

var _time := 0.0

@onready var _timer: Timer = $ShakeTimer


func shake() -> void:
	enabled = true
	make_current()
	_timer.start(duration)


func _process(delta: float) -> void:
	_time += delta
	var strength := pow(trauma, 2)
	offset.x = noise.get_noise_3d(_time * 400, 0, 0) * max_x * strength
	offset.y = noise.get_noise_3d(0, _time * 400, 0) * max_y * strength


func _on_shake_timer_timeout() -> void:
	offset = Vector2.ZERO
	enabled = false
