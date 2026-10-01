extends Control


func _on_Start_pressed():
	get_tree().change_scene_to_file("res://Src/CutScenes/IntroMitch.tscn")


func _on_Options_pressed():
	get_tree().change_scene_to_file("res://Src/Interface/Menus/OptionMenu.tscn")


func _on_Quit_pressed():
	get_tree().quit()
