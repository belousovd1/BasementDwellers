class_name DeathMenu
extends Control
## Shown when the player dies; ToBeContinued.tscn reuses it after a win.
## Restart goes straight back into the last fight.

## The fight Restart goes back to. Each fight sets it when it starts.
static var fight_scene := "res://Src/Interface/Main.tscn"


func _on_Restart_pressed() -> void:
	get_tree().change_scene_to_file(fight_scene)


func _on_Quit_pressed() -> void:
	get_tree().quit()
