extends Projectile
## A spinning paintbrush that flies straight along [member direction] and frees
## itself once it leaves the screen.

@export var speed := 300.0
@export var spin_speed := 8.5

var direction := Vector2.ZERO


func _process(delta: float) -> void:
	rotate(spin_speed * delta)
	position += direction.normalized() * speed * delta


func _on_screen_exited() -> void:
	queue_free()
