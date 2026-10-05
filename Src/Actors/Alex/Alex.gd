class_name Alex
extends Boss
## The final boss: a musician who fights with his guitar and keeps time, nodding
## along to the beat. For the encore, confetti starts falling around him. His
## stages, dialogue and banter are set on Alex.tscn.

@onready var _confetti: Node2D = $Confetti
@onready var _power_up_sound: AudioStreamPlayer = $PowerUpSound


## Starts the confetti, for the encore.
func power_up() -> void:
	if _confetti.running:
		return
	_confetti.start()
	_power_up_sound.play()
