extends Node
## Player settings that persist between sessions (autoload "Settings").
## Currently the Music and SFX bus volumes, applied at startup.

const PATH := "user://settings.cfg"
const VOLUME_BUSES: Array[StringName] = [&"Music", &"SFX"]

var _config := ConfigFile.new()


func _ready() -> void:
	_config.load(PATH)  # On the first run there is no file yet; defaults apply.
	for bus in VOLUME_BUSES:
		_apply_volume(bus, get_volume(bus))


## Volume of [param bus] from 0 (silent) to 1 (full).
func get_volume(bus: StringName) -> float:
	return _config.get_value("audio", bus, 1.0)


## Sets and applies a bus volume from 0 to 1. Call [method save] to keep it.
func set_volume(bus: StringName, volume: float) -> void:
	_config.set_value("audio", bus, volume)
	_apply_volume(bus, volume)


func save() -> void:
	_config.save(PATH)


func _apply_volume(bus: StringName, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(index, linear_to_db(volume))
	AudioServer.set_bus_mute(index, volume <= 0.0)
