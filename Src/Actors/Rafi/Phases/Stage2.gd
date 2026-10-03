extends GabeStage
## Stage 2 (placeholder): Gabe's moves. Apples, traffic and the beach ball.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	call_out("Gabe's moves. Seen them.")
	await wait(1.5)
	resume()


func resume() -> void:
	for x in [-200, -60, 80, 220, -140, 140]:
		spawn_apple(Vector2(x, -310), Vector2(-0.25 * signf(x), 1), 300)
		await wait(0.4)
	await wait(1.0)

	var clear := rng.randi_range(0, LANES.size() - 1)
	for lane in LANES.size():
		if lane != clear:
			spawn_car(lane, rng.randf() < 0.5, 1.0)
	await wait(2.2)

	spawn_beach_ball(Vector2.ZERO, 2, 1.1, 5.0)
	await wait(1.5)
	for y in [-150, 150, 0]:
		spawn_apple(Vector2(-440, y), Vector2.RIGHT, 320)
		await wait(0.9)
	await wait(3.0)
	attacks_finished.emit()
