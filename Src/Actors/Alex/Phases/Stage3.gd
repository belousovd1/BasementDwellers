extends AlexStage
## Stage 3: the encore. Records bounce around the arena for the whole round,
## while the giant bubble rolls through, gems drop, the equalizer jumps and
## coloured notes rain down. The records leave during the player's turn and
## come back fresh each round.

const RECORD_STARTS: Array[Vector2] = [Vector2(-1, -1), Vector2(1, 1), Vector2(1, -1)]
const NOTE_COLORS: Array[Color] = [
	Color("e8417a"), Color("f7d13c"), Color("5fcde4"), Color("99e550"), Color("f5872b"),
]
## At or below this health, a third record joins and everything is a bit faster.
const ENRAGE_HEALTH := 50

var rng := RandomNumberGenerator.new()
var _records: Array[Bouncer] = []
var _record_count := 2
var _speed := 1.0


func start() -> void:
	rng.randomize()
	call_out("Encore!")
	_launch_records()
	await beats(3)
	resume()


func resume() -> void:
	spawn_bubble(rng.randf_range(-120, 120), rng.randf() < 0.5, 150 * _speed)
	for lane in [1, 3, 0, 4, 2, 1, 3, 2]:
		spawn_gem(lane, 0.7, 800 * _speed)
		await beats(1)
	await beats(2)

	call_out("One more time!")
	spawn_equalizer(random_equalizer(rng, 4, 8, 0.7))
	await beats(9)

	for _note in 8:
		spawn_note(Vector2(rng.randf_range(-240, 240), -310), Vector2.DOWN, 300 * _speed, 30, false,
				NOTE_COLORS.pick_random())
		await beats(0.5)
	await beats(4)
	attacks_finished.emit()


func on_player_turn_started() -> void:
	for record in _records:
		if is_instance_valid(record):
			record.queue_free()
	_records.clear()


func on_player_turn_ended(boss_health: int) -> void:
	if boss_health <= ENRAGE_HEALTH:
		_record_count = RECORD_STARTS.size()
		_speed = 1.25
	_launch_records()


## Records appear in the corners, away from the middle, and set off inwards.
func _launch_records() -> void:
	for i in _record_count:
		var corner := RECORD_STARTS[i]
		_records.append(spawn_vinyl(corner * (ARENA_HALF_SIZE - Vector2(60, 60)), -corner, 230 * _speed))
