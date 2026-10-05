extends Node
## How far the player has got, saved between sessions (autoload "Progress").
## Beating a boss unlocks the entrance of the boss after it, and the Load
## screen only offers entrances that are unlocked.

const PATH := "user://progress.cfg"
const SECTION := "unlocked"

var _config := ConfigFile.new()


func _ready() -> void:
	_config.load(PATH)  # On the first run there is no file yet; nothing is unlocked.


## Unlocks [param scene] (a scene path such as a boss's entrance) and saves.
func unlock(scene: String) -> void:
	if is_unlocked(scene):
		return
	_config.set_value(SECTION, _key(scene), true)
	_config.save(PATH)


func is_unlocked(scene: String) -> bool:
	return _config.get_value(SECTION, _key(scene), false)


## Saved by the scene's file name, which keeps the file readable.
func _key(scene: String) -> String:
	return scene.get_file().get_basename()
