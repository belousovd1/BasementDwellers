extends MitchStage
## Stage 2: leg kicks, plus faster paintbrushes and rows.

const SPEED := 400.0


func resume() -> void:
	var legs := spawn_leg_attack()
	await wait(5)
	legs.queue_free()

	spawn_boomerang(Vector2(0, 600), Vector2.UP, SPEED)
	await wait(2)

	for _round in 3:
		for gap in 3:
			spawn_boomerang_row(gap, Vector2(400, 264), Vector2.LEFT, 90, SPEED)
			await wait(0.6, true)
	await wait(3)

	spawn_boomerang(Vector2(0, 600), Vector2.UP, SPEED)
	spawn_boomerang_row(1, Vector2.ZERO, Vector2.DOWN, 0, SPEED)
	await wait(2)
	spawn_boomerang(Vector2.ZERO, Vector2.DOWN, SPEED)
	spawn_boomerang_row(1, Vector2(0, 600), Vector2.UP, 0, SPEED)
	await wait(2)

	_side_sweep(Vector2.LEFT)
	await wait(1.5)
	_side_sweep(Vector2.LEFT)
	await wait(2)
	_side_sweep(Vector2.RIGHT)
	await wait(2)

	legs = spawn_leg_attack(true)
	await wait(7)
	legs.queue_free()
	await wait(1)
	attacks_finished.emit()


## A paintbrush travelling [param direction] across the arena, and a gapped
## row coming the other way.
func _side_sweep(direction: Vector2) -> void:
	spawn_boomerang(Vector2(-600 * direction.x, 264), direction, SPEED)
	spawn_boomerang_row(1, Vector2(600 * direction.x, 264), -direction, 90, SPEED)
