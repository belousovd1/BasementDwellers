extends BossStage
## Stage 1: paintbrushes only.


func start() -> void:
	spawn_boomerang_sweep()
	await wait(2)
	_crossfire()
	await wait(3)
	_drop_pair()
	await wait(2)
	resume()


func resume() -> void:
	spawn_boomerang_sweep()
	await wait(1)
	_crossfire()
	await wait(2)
	_drop_pair()
	await wait(2)
	for i in 3:
		for gap in 3:
			spawn_boomerang_row(gap)
			await wait(1)
	await wait(2)
	attacks_finished.emit()


## Two paintbrushes crossing the arena from opposite sides.
func _crossfire() -> void:
	spawn_boomerang(Vector2(400, 150), Vector2.LEFT)
	spawn_boomerang(Vector2(-400, 350), Vector2.RIGHT)


## Two paintbrushes dropping straight down either side of the centre.
func _drop_pair() -> void:
	spawn_boomerang(Vector2(48, 0), Vector2.DOWN)
	spawn_boomerang(Vector2(-48, 0), Vector2.DOWN)
