extends Control
## Shown when the player dies; ToBeContinued.tscn reuses it after a win.
## Restart goes straight back into the fight.

const FIGHT_SCENE := "res://Src/Interface/Main.tscn"


func _on_Restart_pressed() -> void:
	get_tree().change_scene_to_file(FIGHT_SCENE)


func _on_Quit_pressed() -> void:
	get_tree().quit()
