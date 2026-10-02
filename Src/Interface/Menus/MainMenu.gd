extends Control
## The title screen. (The Load button is not hooked up yet.)

const INTRO_SCENE := "res://Src/CutScenes/IntroMitch.tscn"
const OPTIONS_SCENE := "res://Src/Interface/Menus/OptionMenu.tscn"


func _on_Start_pressed() -> void:
	get_tree().change_scene_to_file(INTRO_SCENE)


func _on_Options_pressed() -> void:
	get_tree().change_scene_to_file(OPTIONS_SCENE)


func _on_Quit_pressed() -> void:
	get_tree().quit()
