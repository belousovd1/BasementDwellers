extends Control
## The title screen. Start begins the story from the first boss; Load picks
## which boss to fight.

const INTRO_SCENE := "res://Src/CutScenes/IntroMitch.tscn"
const LOAD_SCENE := "res://Src/Interface/Menus/BossSelect.tscn"
const OPTIONS_SCENE := "res://Src/Interface/Menus/OptionMenu.tscn"


func _on_Start_pressed() -> void:
	get_tree().change_scene_to_file(INTRO_SCENE)


func _on_Load_pressed() -> void:
	get_tree().change_scene_to_file(LOAD_SCENE)


func _on_Options_pressed() -> void:
	get_tree().change_scene_to_file(OPTIONS_SCENE)


func _on_Quit_pressed() -> void:
	get_tree().quit()
