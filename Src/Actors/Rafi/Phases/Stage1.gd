extends MikeStage
## Stage 1 (placeholder): Mike's moves, done faster. Cubes, rows of vertices
## and loop cuts.

const SPEED := 1.25


func start() -> void:
	call_out("Mike's moves. Faster.")
	await wait(1.5)
	resume()


func resume() -> void:
	for x in [-180, 60, -60, 180, 0, -120, 120]:
		spawn_cube(Vector2(x, -300), Vector2.DOWN, 250 * SPEED)
		await wait(0.45)
	await wait(1.2)

	for y in [-120, 60, 150, -30]:
		spawn_loop_cut(y, false, 0.7)
		await wait(0.5)
	spawn_loop_cuts(3, true, 0.8)
	await wait(1.6)

	for gap in [1, 5, 3]:
		spawn_edge_wall(Vector2(0, -300), Vector2.DOWN, gap, 2, 200 * SPEED)
		await wait(1.1)
	await wait(2.5)
	attacks_finished.emit()
