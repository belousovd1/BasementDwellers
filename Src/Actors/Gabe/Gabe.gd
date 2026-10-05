class_name Gabe
extends Boss
## The third boss: an Apple Genius and car guy who poses like he's in JoJo's
## Bizarre Adventure and can't stop quoting Dunkey. Dunkey blesses him at the
## end of his entrance, and he wears the halo for the whole fight. For his final
## stage the air around him turns menacing. His stages, dialogue and banter are
## set on Gabe.tscn.

@onready var _menacing: Node2D = $Menacing
@onready var _power_up_sound: AudioStreamPlayer = $PowerUpSound
@onready var _halo: Node2D = $Halo


## He fights blessed, from the first stage on.
func start_stage(index: int) -> void:
	super(index)
	if index == 0:
		bless()


## Puts Dunkey's halo over his head, floating down over [param descend_time]
## seconds, or there at once if that is 0.
func bless(descend_time := 0.0) -> void:
	_halo.appear(descend_time)


## Fills the air around Gabe with menacing ゴゴゴ.
func menace() -> void:
	_menacing.start()


## Turns menacing for the final stage.
func power_up() -> void:
	if _menacing.running:
		return
	menace()
	_power_up_sound.play()
