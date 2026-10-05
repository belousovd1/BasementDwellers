extends GabeStage
## Stage 1: the Genius Bar. Apple logos, rapid apple shots down lines of fire,
## and the spinning beach ball.

var rng := RandomNumberGenerator.new()


func start() -> void:
	rng.randomize()
	await wait(1.5)
	resume()


func resume() -> void:


	# Rapid shots from above, each aimed at wherever the player is standing.
	call_out("EAT CORPERATE TECH.")
	for x in [-200, 120, -60, 220, -160, 40, 180, -100, 0, 140]:
		var from := Vector2(x, -310)
		spawn_apple_shot(from, player_position() - from)
		await wait(0.3)
	await wait(1.2)
	

	# Apples rain down from Gabe, slanting in towards the middle.
	for x in [-200, -60, 80, 220, -140, 140]:
		spawn_apple(Vector2(x, -310), Vector2(-0.25 * signf(x), 1))
		await wait(0.5)
	await wait(1.0)

	# The beach ball spins in the middle while shots rip across the arena from
	# alternating sides.
	call_out("I'm gonna put your head in a jar, and fuck you for a life time")
	spawn_beach_ball()
	await wait(1.6)
	for i in 10:
		var side := -1.0 if i % 2 == 0 else 1.0
		spawn_apple_shot(Vector2(440 * side, rng.randf_range(-200, 200)), Vector2(-side, 0))
		await wait(0.4)
	await wait(1.5)
	call_out("you skin stealing FUCK.")

	# Shots from every side at once, all aimed at the player.
	for _shot in 14:
		var angle := rng.randf() * TAU
		var from := Vector2.from_angle(angle) * 480
		spawn_apple_shot(from, player_position() - from, 0.5)
		await wait(0.25)
	await wait(2.0)
	attacks_finished.emit()
