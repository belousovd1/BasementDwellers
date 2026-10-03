extends GabeStage
## Stage 3 (placeholder): everything at once. Tyres bounce around the arena
## while road rollers drop on the player, traffic speeds through and rainbow
## apples rain down. The tyres leave during the player's turn and come back
## fresh each round.

const TIRE_STARTS: Array[Vector2] = [Vector2(-1, -1), Vector2(1, 1), Vector2(1, -1)]
## At or below this health, a third tyre joins and everything is a bit faster.
const ENRAGE_HEALTH := 50

var rng := RandomNumberGenerator.new()
var _tires: Array[Tire] = []
var _tire_count := 2
var _speed := 1.1


func start() -> void:
	rng.randomize()
	call_out("All of it. At once.")
	_launch_tires()
	await wait(1.5)
	resume()


func resume() -> void:
	for _roller in 3:
		spawn_road_roller(player_position(), 0.9 / _speed)
		await wait(1.3)
	await wait(0.8)

	var from_left := rng.randf() < 0.5
	for lane in LANES.size():
		spawn_car(lane, from_left, 0.8, 1000 * _speed)
		from_left = not from_left
		await wait(0.45)
	await wait(1.2)

	for _apple in 8:
		spawn_apple(Vector2(rng.randf_range(-240, 240), -310), Vector2.DOWN, 300 * _speed, true)
		await wait(0.32)
	await wait(2.0)
	attacks_finished.emit()


func on_player_turn_started() -> void:
	for tire in _tires:
		if is_instance_valid(tire):
			tire.queue_free()
	_tires.clear()


func on_player_turn_ended(boss_health: int) -> void:
	if boss_health <= ENRAGE_HEALTH:
		_tire_count = TIRE_STARTS.size()
		_speed = 1.35
	_launch_tires()


## Tyres appear in the corners, away from the middle, and set off inwards.
func _launch_tires() -> void:
	for i in _tire_count:
		var corner := TIRE_STARTS[i]
		_tires.append(spawn_tire(corner * (ARENA_HALF_SIZE - Vector2(60, 60)), -corner, 230 * _speed))
