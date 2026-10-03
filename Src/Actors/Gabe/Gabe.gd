class_name Gabe
extends Boss
## The third boss: an Apple Genius and car guy who poses like he's in JoJo's
## Bizarre Adventure and can't stop quoting Dunkey. For his final stage the air
## around him turns menacing. His stages, dialogue and banter are set on
## Gabe.tscn.

@onready var _menacing: Node2D = $Menacing
@onready var _power_up_sound: AudioStreamPlayer = $PowerUpSound


## Fills the air around Gabe with menacing ゴゴゴ.
func menace() -> void:
	_menacing.start()


## Turns menacing for the final stage.
func power_up() -> void:
	if _menacing.running:
		return
	menace()
	_power_up_sound.play()
