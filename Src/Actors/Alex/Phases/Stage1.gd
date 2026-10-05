extends AlexStage
## Stage 1: the soundcheck. A melody of notes weaving across the arena, then
## sight-reading along the staff, then notes raining down.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	call_out("Check, one, two.")
	await beats(3)
	resume()


func resume() -> void:
	# A melody: notes weave in from alternate sides, one to a beat.
	for i in 8:
		var side := 1 if i % 2 == 0 else -1
		spawn_note(Vector2(440 * side, rng.randf_range(-170, 170)), Vector2(-side, 0), 280, 40, i % 3 == 2)
		await beats(1)
	await beats(2)

	# Sight-reading: bars of notes slide along the staff's lines, so stand in
	# the spaces between them. The second bar comes once the first has gone.
	call_out("Sight-read this!")
	await play_staff([0, 2, 4])
	await beats(8)
	await play_staff([1, 3])
	await beats(8)

	# Notes rain down from Alex, two to a beat.
	for x in [-200, 120, -40, 220, -160, 40, 180, -100]:
		spawn_note(Vector2(x, -310), Vector2.DOWN, 280, 30)
		await beats(0.5)
	await beats(4)
	attacks_finished.emit()
