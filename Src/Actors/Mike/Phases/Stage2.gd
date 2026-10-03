extends MikeStage
## Stage 2: edit mode. Loop cuts, faces extruded from the walls, and faster
## cubes and rows.

const SPEED := 340.0


func start() -> void:
	call_out("Tab. Edit mode.")
	await wait(1.5)
	resume()


func resume() -> void:
	# Loop cuts one at a time: across, then down.
	call_out("Ctrl+R!")
	for y in [-110, 60, 150, -30]:
		spawn_loop_cut(y)
		await wait(0.6)
	await wait(0.6)
	for x in [-140, 140, 0]:
		spawn_loop_cut(x, true)
		await wait(0.6)
	await wait(1.2)

	# Several cuts at once, leaving lanes to stand in.
	spawn_loop_cuts(4)
	await wait(1.6)
	spawn_loop_cuts(4, true)
	await wait(1.6)

	# Faces extruded from the walls, then a pincer from both sides.
	call_out("E!")
	spawn_extrude(Vector2.LEFT, -110)
	await wait(0.9)
	spawn_extrude(Vector2.RIGHT, 110)
	await wait(0.9)
	spawn_extrude(Vector2.UP, -140, 200)
	await wait(0.9)
	spawn_extrude(Vector2.UP, 140, 200)
	await wait(1.2)
	spawn_extrude(Vector2.LEFT, 0, 300, 200)
	spawn_extrude(Vector2.RIGHT, 0, 300, 200)
	await wait(1.8)

	# Faster cubes and rows coming at once from the sides.
	for y in [-150, 150]:
		spawn_cube(Vector2(-440, y), Vector2.RIGHT, SPEED)
		spawn_edge_wall(Vector2(-330, 0), Vector2.RIGHT, 2 if y < 0 else 3, 1, SPEED * 0.6)
		await wait(1.6)
	await wait(2)
	attacks_finished.emit()
