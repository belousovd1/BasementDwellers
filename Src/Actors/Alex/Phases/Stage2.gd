extends AlexStage
## Stage 2: the rhythm game. Gems drop down the note highway's lanes on the
## beat, then chords of them, then the equalizer jumps while notes fly over it.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	call_out("Grab a controller.")
	await beats(3)
	resume()


func resume() -> void:
	call_out("Note highway!")
	for lane in [0, 2, 4, 1, 3, 2, 0, 4]:
		spawn_gem(lane)
		await beats(1)
	await beats(1)
	for chord in [[0, 1], [3, 4], [1, 2, 3], [0, 4], [0, 1, 2], [2, 3, 4]]:
		spawn_chord(chord)
		await beats(2)
	await beats(2)

	# The equalizer jumps on the floor; notes fly over the top of it.
	call_out("Drop the bass!")
	spawn_equalizer(random_equalizer(rng, 6))
	await beats(2)
	for _note in 6:
		spawn_note(Vector2(440, rng.randf_range(-200, -60)), Vector2.LEFT, 300, 25)
		await beats(2)
	await beats(4)
	attacks_finished.emit()
