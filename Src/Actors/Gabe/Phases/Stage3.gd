extends GabeStage
## Stage 3: menacing. Gabe summons Gerald, his first car, an old Subaru
## Forester, who rises out of a summoning circle and hunts the player all over
## the screen for the whole round. Traffic speeds through and rainbow apples
## rain down, with stretches between where it's just him. Gerald drives off for
## the player's turn and is summoned again after it.

## Where Gerald is summoned: between Gabe and the top of the arena.
const SUMMON_AT := Vector2(0, -400)

## At or below this health, Gerald drives and charges harder and everything else
## is a bit faster.
const ENRAGE_HEALTH := 50

var rng := RandomNumberGenerator.new()
var _gerald: Node2D
var _speed := 1.0


func start() -> void:
	rng.randomize()
	call_out("Come forth... GERALD!")
	_summon_gerald()
	await wait(2.2)
	resume()


func resume() -> void:
	# Just Gerald for a while.
	await wait(3.0)
	await _traffic()
	await wait(1.0)

	# Rainbow apples rain down at random.
	for _apple in 10:
		spawn_apple(Vector2(rng.randf_range(-240, 240), -310), Vector2.DOWN, 280 * _speed, true)
		await wait(0.35)
	await wait(1.0)

	# Gerald on his own again, then one last rush of traffic.
	await wait(4.0)
	await _traffic()
	await wait(2.0)
	attacks_finished.emit()


## Traffic in every lane, one after another, alternating sides.
func _traffic() -> void:
	var from_left := rng.randf() < 0.5
	for lane in LANES.size():
		spawn_car(lane, from_left, 0.8, 1000 * _speed)
		from_left = not from_left
		await wait(0.5)


func on_player_turn_started() -> void:
	if is_instance_valid(_gerald):
		_gerald.leave()


func on_player_turn_ended(boss_health: int) -> void:
	if boss_health <= ENRAGE_HEALTH:
		_speed = 1.25
	_summon_gerald()


func _summon_gerald() -> void:
	if is_instance_valid(_gerald):
		_gerald.queue_free()
	_gerald = spawn_gerald(SUMMON_AT, 380 * _speed, 2.2 / _speed)
