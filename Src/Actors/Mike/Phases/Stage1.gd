extends MikeStage
## Stage 1: the default cube, and rows of vertices.

## Edges left out of each row in the volley; each row's gap is two edges wide.
const ROW_GAPS: Array[int] = [1, 5, 2, 4]


func start() -> void:
	call_out("Behold. The default cube.")
	await wait(1.5)
	resume()


func resume() -> void:
	# Cubes rain down from Mike across the arena.
	for x in [-160, 80, -40, 200, -200, 40]:
		spawn_cube(Vector2(x, -300), Vector2.DOWN)
		await wait(0.55)
	await wait(1.5)

	# Crossfire from both sides, at mirrored heights.
	for y in [-120, 120, 0]:
		spawn_cube(Vector2(-440, y), Vector2.RIGHT, 300)
		spawn_cube(Vector2(440, -y), Vector2.LEFT, 300)
		await wait(1.1)
	await wait(1.2)

	# Rows of vertices dropping through, each with its gap somewhere new.
	for gap in ROW_GAPS:
		spawn_edge_wall(Vector2(0, -300), Vector2.DOWN, gap, 2)
		await wait(1.3)
	await wait(2.5)
	attacks_finished.emit()
