extends MitchStage
## Stage 2: Mitch passes his kidney stones and drops them on the player, plus
## faster paintbrushes and rows.

const SPEED := 400.0
## How far inside the arena walls the stones land.
const STONE_MARGIN := Vector2(50, 50)


func resume() -> void:
	# Kidney stones dropped one after another onto the player.
	call_out("Pass... the... STONE!")
	for _stone in 6:
		spawn_kidney_stone(_near_player(), false, 0.9)
		await wait(0.75)
	await wait(1.0)

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

	# The big ones: stones that shatter as they land, the player's spot and
	# somewhere else at once.
	call_out("Here comes the big one!")
	for i in 8:
		spawn_kidney_stone(_near_player(), true, 0.8)
		if i % 2 == 1:
			spawn_kidney_stone(_anywhere(), true, 0.8)
		await wait(0.75)
	await wait(1.5)
	attacks_finished.emit()


## Just about where the player is standing, inside the arena.
func _near_player() -> Vector2:
	var at := player_position() + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var room := ArenaStage.ARENA_HALF_SIZE - STONE_MARGIN
	return at.clamp(-room, room)


## Somewhere random in the arena.
func _anywhere() -> Vector2:
	var room := ArenaStage.ARENA_HALF_SIZE - STONE_MARGIN
	return Vector2(randf_range(-room.x, room.x), randf_range(-room.y, room.y))


## A paintbrush travelling [param direction] across the arena, and a gapped
## row coming the other way.
func _side_sweep(direction: Vector2) -> void:
	spawn_boomerang(Vector2(-600 * direction.x, 264), direction, SPEED)
	spawn_boomerang_row(1, Vector2(600 * direction.x, 264), -direction, 90, SPEED)
