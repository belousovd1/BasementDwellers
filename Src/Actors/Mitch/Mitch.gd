class_name Mitch
extends Boss
## The first boss. His stages, dialogue and banter are set on Mitch.tscn.


## Switches Mitch to his stage 3 idle animation.
func power_up() -> void:
	idle_animation = "stage3_idle"
	play_idle()


## Once his last stage is beaten he calms back down to his usual look for his
## parting words.
func end_stage() -> void:
	super()
	idle_animation = "idle"
	play_idle()
