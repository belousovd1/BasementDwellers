extends Control
## Volume settings. The first slider sets the Master bus volume in dB; the
## sound-effects slider is not hooked up yet.

const MAIN_MENU := "res://Src/Interface/Menus/MainMenu.tscn"


func _on_HSlider_value_changed(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)


func _on_Back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
