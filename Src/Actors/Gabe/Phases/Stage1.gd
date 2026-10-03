extends GabeStage
## Stage 1: the Genius Bar. Apple logos, and the spinning beach ball.


func start() -> void:
	call_out("Welcome to the Genius Bar.")
	await wait(1.5)
	resume()


func resume() -> void:
	# Apples rain down from Gabe, slanting in towards the middle.
	for x in [-200, -60, 80, 220, -140, 140]:
		spawn_apple(Vector2(x, -310), Vector2(-0.25 * signf(x), 1))
		await wait(0.5)
	await wait(1.2)

	# The beach ball spins in the middle while apples fly through.
	call_out("It's not frozen. It's thinking.")
	spawn_beach_ball()
	await wait(2.5)
	for y in [-150, 150]:
		spawn_apple(Vector2(-440, y), Vector2.RIGHT, 300)
		await wait(1.2)
	await wait(3.0)

	# Apples from both sides at once, at staggered heights.
	for y in [-140, 0, 140]:
		spawn_apple(Vector2(-440, y - 30), Vector2.RIGHT, 320)
		spawn_apple(Vector2(440, y + 40), Vector2.LEFT, 320)
		await wait(0.9)
	await wait(2.0)
	attacks_finished.emit()
