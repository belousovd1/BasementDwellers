extends Node2D
## Malocchio's laser. The fire animations sweep the RayCast2D out along the
## beam; while [member armed], any body the ray touches takes [member damage].

## Emitted by the fire animations' method track once the beam has finished.
signal finished

@export var damage := 20

## Only a Malocchio flying its attack path can hurt the player; the one shown
## while it is being summoned cannot.
var armed := false

@onready var _ray: RayCast2D = $RayCast2D


func _process(_delta: float) -> void:
	if not armed:
		return
	var target := _ray.get_collider()
	if target and target.has_method("take_hit"):
		target.take_hit(damage)


# Called from the "firelaser" and "FasterFireLaser" animations.
func end_laser_animation() -> void:
	finished.emit()
