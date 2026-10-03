extends GabeStage
## Stage 2: the car guy. Traffic through the arena's lanes, then rush hour with
## every lane but one, then a faster beach ball with apples.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	call_out("Wanna see my car?")
	await wait(1.5)
	resume()


func resume() -> void:
	# One lane at a time, alternating sides.
	call_out("Beep beep!")
	for lane in LANES.size():
		spawn_car(lane, lane % 2 == 0)
		await wait(0.7)
	await wait(1.5)

	# Rush hour: every lane at once, bar one.
	call_out("Rush hour!")
	for _wave in 2:
		var clear := rng.randi_range(0, LANES.size() - 1)
		for lane in LANES.size():
			if lane != clear:
				spawn_car(lane, rng.randf() < 0.5, 1.1)
		await wait(2.2)

	# A faster beach ball off to one side, turning the other way, with apples
	# coming from the other side.
	spawn_beach_ball(Vector2(-130, 0), 1, -1.6, 5.0)
	await wait(1.0)
	for y in [-120, 40, 160, -40]:
		spawn_apple(Vector2(440, y), Vector2.LEFT, 300)
		await wait(0.9)
	await wait(2.5)
	attacks_finished.emit()
