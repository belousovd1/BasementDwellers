extends Control
## Music and sound-effect volume. Changes are heard immediately (the menu music
## and the fire's crackle) and saved when leaving the menu.

const MAIN_MENU := "res://Src/Interface/Menus/MainMenu.tscn"

@onready var _music_slider: HSlider = %MusicVolume
@onready var _sfx_slider: HSlider = %SfxVolume


func _ready() -> void:
	_music_slider.set_value_no_signal(Settings.get_volume(&"Music"))
	_sfx_slider.set_value_no_signal(Settings.get_volume(&"SFX"))


func _exit_tree() -> void:
	Settings.save()


func _on_music_volume_changed(volume: float) -> void:
	Settings.set_volume(&"Music", volume)


func _on_sfx_volume_changed(volume: float) -> void:
	Settings.set_volume(&"SFX", volume)


func _on_Back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
