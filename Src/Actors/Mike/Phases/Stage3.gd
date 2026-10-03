extends MikeStage
## Stage 3: the render. Tiles of the arena render one after another and loop
## cuts slice through, while Blender's 3D cursor follows the player and Mike
## adds a cube wherever it stops (Shift+A).

const Cursor3DScene := preload("res://Src/Actors/Mike/Attacks/Cursor3D.tscn")
## The render grid laid over the arena.
const TILES := Vector2i(4, 3)
## Seconds between cubes added at the 3D cursor, and how long it blinks first.
const ADD_INTERVAL := 2.2
const ENRAGED_ADD_INTERVAL := 1.5
const LOCK_TIME := 0.6
const CUBE_SPEED := 230.0
## At or below this health, cubes come more often and more tiles render at once.
const ENRAGE_HEALTH := 50

var rng := RandomNumberGenerator.new()
var _cursor: Node2D
var _threads := 2
var _add_interval := ADD_INTERVAL
var _enraged := false


func start() -> void:
	rng.randomize()
	_cursor = Cursor3DScene.instantiate()
	_cursor.position = Vector2(0, -150)
	arena.add_child(_cursor)
	_add_cubes()
	await wait(1.5)
	resume()


func _process(_delta: float) -> void:
	_cursor.target = player_position()


func resume() -> void:
	call_out("F12!")
	await _render_in_order(_tile_order(rng.randi_range(0, 2)))
	await wait(1.0)

	for _cut in 3:
		spawn_loop_cut(rng.randf_range(-170, 170))
		await wait(0.5)
		spawn_loop_cut(rng.randf_range(-220, 220), true)
		await wait(0.7)
	await wait(0.8)

	# Everything renders at once, bar a couple of tiles.
	call_out("Render all!")
	var tiles := _all_tiles()
	tiles.shuffle()
	for tile in tiles.slice(2):
		spawn_render_tile(tile, TILES, 1.2)
	await wait(2.0)

	await _render_in_order(_tile_order(rng.randi_range(0, 2)))
	await wait(1.5)
	attacks_finished.emit()


func on_player_turn_started() -> void:
	_cursor.hide()


func on_player_turn_ended(boss_health: int) -> void:
	if boss_health <= ENRAGE_HEALTH and not _enraged:
		_enraged = true
		_threads = 3
		_add_interval = ENRAGED_ADD_INTERVAL
		_cursor.speed *= 1.3
	_cursor.show()


## Adds a cube at the 3D cursor every so often, for as long as the stage lasts.
## The cursor stops and blinks first, and the cube flies off in any direction.
func _add_cubes() -> void:
	while true:
		await wait(_add_interval)
		if not _cursor.visible:
			continue
		_cursor.lock()
		await wait(LOCK_TIME)
		if _cursor.visible:
			spawn_cube(_cursor.position, Vector2.from_angle(rng.randf() * TAU), CUBE_SPEED)
		_cursor.unlock()


## Renders every tile in [param order], [member _threads] tiles at a time.
func _render_in_order(order: Array[Vector2i]) -> void:
	for i in range(0, order.size(), _threads):
		for tile in order.slice(i, i + _threads):
			spawn_render_tile(tile, TILES)
		await wait(0.6)


## Blender's tile orders: left to right, top to bottom, or from the middle out.
func _tile_order(kind: int) -> Array[Vector2i]:
	var tiles := _all_tiles()
	var middle := Vector2(TILES - Vector2i.ONE) / 2
	match kind:
		0:
			tiles.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
				return a.x < b.x or a.x == b.x and a.y < b.y)
		1:
			tiles.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
				return a.y < b.y or a.y == b.y and a.x < b.x)
		_:
			tiles.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
				return Vector2(a).distance_to(middle) < Vector2(b).distance_to(middle))
	return tiles


func _all_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for x in TILES.x:
		for y in TILES.y:
			tiles.append(Vector2i(x, y))
	return tiles
