extends GabeStage
## Stage 2: the garage. Gabe throws his wrenches, takes his car for a test
## drive weaving through the lanes, floors it through rush hour, then sets ice
## cream cakes on the arena walls shooting slices of themselves.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	call_out("If you can dodge a wrench, you can dodge a CAR!!.")
	await wait(1.5)
	resume()


func resume() -> void:
	# Wrenches thrown end over end at wherever the player is standing.
	for x in [-180, 160, -40, 220, -220, 60]:
		var from := Vector2(x, -310)
		spawn_wrench(from, player_position() - from)
		await wait(0.6)
	await wait(1.2)
	call_out("let's see you dodge neither, you little shit.")

	# Test drive: one car weaving back and forth through the lanes, faster
	# every pass.
	var paint: Color = CAR_PAINTS.pick_random()
	var from_left := rng.randf() < 0.5
	var speed := 800.0
	for lane in [0, 2, 4, 3, 1]:
		spawn_car(lane, from_left, 0.7, speed, paint)
		from_left = not from_left
		speed += 90.0
		await wait(0.8)
	await wait(1.5)

	# Rush hour: every lane at once, bar one.

	for _wave in 2:
		var clear := rng.randi_range(0, LANES.size() - 1)
		for lane in LANES.size():
			if lane != clear:
				spawn_car(lane, rng.randf() < 0.5, 1.1)
		await wait(2.2)

	# Ice cream cakes shooting slices of themselves: down from the top wall,
	# then across from both sides at once.
	call_out("This was gonna be ice cream cake for alex, buttttt")
	spawn_ice_cream_cake(Vector2.UP)
	await wait(4.5)
	call_out(" HE CAN WAIT TELL HE'S THRITY!!")
	spawn_ice_cream_cake(Vector2.LEFT, -110)
	spawn_ice_cream_cake(Vector2.RIGHT, 110)
	await wait(5.5)
	attacks_finished.emit()
